#!/usr/bin/env python3
"""
Simple Hermes Sub-Agent — receives tasks via Telegram, executes them with tools.
No complex hermes framework — just API + tools.
"""
import json, os, sys, subprocess, time, urllib.request

BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "")
API_KEY = os.environ.get("OPENAI_API_KEY", "")
API_URL = os.environ.get("OPENAI_BASE_URL", "https://9router-production-b956.up.railway.app/v1")
CHAT_ID = "-1004378981918"
ALLOWED_USERS = [6856141142]
SYSTEM_PROMPT = """You are Hermes Bot2, a coding assistant. You have access to terminal and file tools.
When given a task, execute it step by step using the terminal tool.
Be concise. Just run commands and report results."""

TOOLS = [
    {"type": "function", "function": {"name": "terminal", "description": "Run shell command", "parameters": {"type": "object", "properties": {"command": {"type": "string"}}, "required": ["command"]}}},
    {"type": "function", "function": {"name": "write_file", "description": "Write content to file", "parameters": {"type": "object", "properties": {"path": {"type": "string"}, "content": {"type": "string"}}, "required": ["path", "content"]}}},
]

def run_command(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30, cwd="/data/workspace")
        return r.stdout + r.stderr
    except Exception as e:
        return str(e)

def call_api(messages):
    data = json.dumps({"model": "hermes.new", "messages": messages, "tools": TOOLS, "stream": False}).encode()
    req = urllib.request.Request(f"{API_URL}/chat/completions", data=data,
        headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}, method="POST")
    resp = urllib.request.urlopen(req, timeout=60)
    raw = resp.read().decode()
    return json.loads(raw.split("\n")[0] if "\n" in raw else raw)

def process_task(task):
    messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": task}]
    for i in range(5):
        try:
            result = call_api(messages)
            choice = result["choices"][0]
            msg = choice["message"]
            if choice.get("finish_reason") == "tool_calls" and msg.get("tool_calls"):
                for tc in msg["tool_calls"]:
                    name = tc["function"]["name"]
                    args = json.loads(tc["function"]["arguments"])
                    if name == "terminal":
                        output = run_command(args["command"])
                    elif name == "write_file":
                        os.makedirs(os.path.dirname(args["path"]), exist_ok=True)
                        with open(args["path"], "w") as f:
                            f.write(args["content"])
                        output = f"Written {len(args['content'])} bytes"
                    else:
                        output = "Unknown tool"
                    messages.append(msg)
                    messages.append({"role": "tool", "tool_call_id": tc["id"], "content": output})
            else:
                return msg.get("content", "Done")
        except Exception as e:
            return f"Error: {e}"
    return "Max iterations reached"

def send_telegram(text):
    data = json.dumps({"chat_id": CHAT_ID, "text": text[:4000]}).encode()
    req = urllib.request.Request(f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage",
        data=data, headers={"Content-Type": "application/json"}, method="POST")
    urllib.request.urlopen(req, timeout=10)

print("Bot2 Sub-Agent started! Waiting for tasks...")
last_update_id = 0
while True:
    try:
        req = urllib.request.Request(f"https://api.telegram.org/bot{BOT_TOKEN}/getUpdates?offset={last_update_id+1}&timeout=5")
        resp = urllib.request.urlopen(req, timeout=15)
        updates = json.loads(resp.read())
        for u in updates.get("result", []):
            last_update_id = u["update_id"]
            msg = u.get("message", {})
            if msg.get("chat", {}).get("id") != int(CHAT_ID):
                continue
            text = msg.get("text", "")
            sender = msg.get("from", {}).get("id", 0)
            if sender not in ALLOWED_USERS:
                continue
            if text.startswith("/"):
                continue
            print(f"Task received: {text[:100]}")
            send_telegram(f"⏳ Processing: {text[:100]}...")
            result = process_task(text)
            send_telegram(f"✅ Result:\n{result[:2000]}")
    except Exception as e:
        print(f"Error: {e}")
        time.sleep(5)
