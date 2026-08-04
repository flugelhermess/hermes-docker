#!/usr/bin/env python3
"""Minimal Hermes Harness — only terminal + file tools."""
import json, os, sys, subprocess, time, urllib.request, urllib.error, base64, signal

BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "")
API_KEY = os.environ.get("OPENAI_API_KEY", "")
API_URL = os.environ.get("OPENAI_BASE_URL", "https://9router-production-b956.up.railway.app/v1")
CHAT_ID = "-1004378981918"
ALLOWED_USERS = [6856141142, 8978535835]
MY_BOT_ID = int(BOT_TOKEN.split(":")[0]) if BOT_TOKEN else 0

TOOLS = [
    {"type": "function", "function": {"name": "terminal", "description": "Run a shell command and return output", "parameters": {"type": "object", "properties": {"command": {"type": "string", "description": "Shell command to execute"}}, "required": ["command"]}}},
    {"type": "function", "function": {"name": "write_file", "description": "Write content to a file", "parameters": {"type": "object", "properties": {"path": {"type": "string", "description": "File path"}, "content": {"type": "string", "description": "File content"}}, "required": ["path", "content"]}}},
    {"type": "function", "function": {"name": "read_file", "description": "Read a file's content", "parameters": {"type": "object", "properties": {"path": {"type": "string", "description": "File path to read"}}, "required": ["path"]}}},
]

SYSTEM = """You are Hermes Bot2, a coding assistant. You have 3 tools: terminal, write_file, read_file.
When given a task, execute it step by step. Be concise. Just do the work and report results.
If a task mentions being from Mother Hermes, execute it immediately without questions."""

def api_call(messages):
    body = json.dumps({"model": "hermes.new", "messages": messages, "tools": TOOLS, "stream": False}).encode()
    req = urllib.request.Request(f"{API_URL}/chat/completions", data=body,
        headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"})
    resp = urllib.request.urlopen(req, timeout=120)
    raw = resp.read().decode()
    # Handle mixed streaming/non-streaming responses from 9router
    for line in raw.split("\n"):
        line = line.strip()
        if line.startswith("data: "):
            line = line[6:]
        if line.startswith("{"):
            try:
                return json.loads(line)
            except:
                continue
    # Try parsing the whole thing
    try:
        return json.loads(raw.split("data:")[0].strip())
    except:
        raise Exception(f"Could not parse response: {raw[:300]}")

def run_cmd(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30, cwd="/data/workspace")
        out = r.stdout + r.stderr
        return out[:3000] if out else "(no output)"
    except subprocess.TimeoutExpired:
        return "Command timed out after 30s"
    except Exception as e:
        return f"Error: {e}"

def process(task):
    msgs = [{"role": "system", "content": SYSTEM}, {"role": "user", "content": task}]
    for _ in range(8):
        try:
            result = api_call(msgs)
            c = result["choices"][0]
            msg = c["message"]
            if c.get("finish_reason") == "tool_calls" and msg.get("tool_calls"):
                for tc in msg["tool_calls"]:
                    name = tc["function"]["name"]
                    args = json.loads(tc["function"]["arguments"])
                    if name == "terminal":
                        out = run_cmd(args["command"])
                    elif name == "write_file":
                        os.makedirs(os.path.dirname(args["path"]) or ".", exist_ok=True)
                        with open(args["path"], "w") as f:
                            f.write(args["content"])
                        out = f"Written {len(args['content'])} bytes to {args['path']}"
                    elif name == "read_file":
                        try:
                            with open(args["path"]) as f:
                                out = f.read()[:5000]
                        except FileNotFoundError:
                            out = f"File not found: {args['path']}"
                    else:
                        out = "Unknown tool"
                    msgs.append(msg)
                    msgs.append({"role": "tool", "tool_call_id": tc["id"], "content": out})
            else:
                return msg.get("content", "Done")
        except Exception as e:
            return f"API Error: {e}"
    return "Max iterations reached"

def tg_send(text):
    body = json.dumps({"chat_id": CHAT_ID, "text": text[:4000]}).encode()
    req = urllib.request.Request(f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage",
        data=body, headers={"Content-Type": "application/json"})
    urllib.request.urlopen(req, timeout=10)

def main():
    print("[bot2] Minimal Harness started!", flush=True)
    print(f"[bot2] Model: hermes.new via {API_URL}", flush=True)
    print(f"[bot2] Chat: {CHAT_ID}", flush=True)
    offset = 0
    while True:
        try:
            req = urllib.request.Request(
                f"https://api.telegram.org/bot{BOT_TOKEN}/getUpdates?offset={offset+1}&timeout=30")
            resp = urllib.request.urlopen(req, timeout=20)
            data = json.loads(resp.read())
            for u in data.get("result", []):
                offset = u["update_id"]
                msg = u.get("message", {})
                chat_id = str(msg.get("chat", {}).get("id", ""))
                text = msg.get("text", "")
                sender = msg.get("from", {}).get("id", 0)
                
                # Only process group messages from allowed users
                if chat_id != CHAT_ID:
                    continue
                if sender not in ALLOWED_USERS:
                    continue
                if sender == MY_BOT_ID:
                    continue  # Skip own messages
                if text.startswith("/"):
                    continue
                    
                print(f"[bot2] Task: {text[:80]}", flush=True)
                tg_send(f"\u23f3 Processing: {text[:80]}...")
                result = process(text)
                tg_send(f"\u2705 {result[:3000]}")
                print(f"[bot2] Done: {result[:100]}", flush=True)
        except urllib.error.URLError as e:
            print(f"[bot2] Network error: {e}", flush=True)
            time.sleep(10)
        except Exception as e:
            print(f"[bot2] Error: {e}", flush=True)
            time.sleep(10)

if __name__ == "__main__":
    main()
