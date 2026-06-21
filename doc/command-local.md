
cc command 的本地模式:
原則上 cc command 會傳送 prompt 給 model，可以透過這樣，不去調用模型
---
disable-model-invocation: true
---

並且使用 UserPromptExpansion hook 在展開階段攔截並執行 shell 腳本



cc command 的步驟: (model 推論的)
1. 使用者輸入 /exit-clean
2. CC 認出這是一個指令（靠 commands/exit-clean.md 存在）
3. UserPromptExpansion hook 觸發
4. hook 回傳 decision: "block" → 流程終止
5. commands 檔案的內容從未送出去
