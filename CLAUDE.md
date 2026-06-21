# exit-clean

| 名稱 | 觸發時機 | Hook 事件 | 環境變數 |
|------|----------|-----------|----------|
| exit-clean（武裝） | 使用者執行 `/exit-clean` | `UserPromptExpansion` | 無 |
| exit-clean（確認） | 武裝後送出任何訊息 | `UserPromptSubmit` | 無 |

## 注意事項

- 確認視窗 60 秒內有效；超時或送出非 `y`/`n` 的訊息均自動取消
- 刪除不可復原；session 歷史檔在 CC 結束後約 0.5 秒被背景程序刪除
- `UserPromptSubmit` hook 對每則訊息都會執行，但未武裝時第一行即放行，無效能影響
