**Dart autocomplete with `.` doesn't work in Zed.**

At first, I thought this was just how it was, but after searching issues, I found that others have the same problem, and it also exists in the latest version of Zed. So I analyzed it and discovered that the Dart LSP doesn't include the `triggerCharacters` field in the results returned during initialization, so Zed doesn't know to trigger completion on `.`.

```json
"completionProvider":{
  "resolveProvider":true,
  "triggerCharacters":["."]
} 
```

I tried writing a wrapper in Dart, and after testing, it correctly triggers completion on `.`. Of course, this is just an experiment to analyze the issue. The specific fix would need to come from Zed's side, since VS Code and Android [Studio work fine]...

You can check the effect in [QQ录屏20260208162526.mp4](QQ录屏20260208162526.mp4)


## **Steps to Test Dart Autocomplete with Zed**

### **1. Prerequisites**
- Install Zed editor
- Have Dart SDK installed and accessible in your PATH
- Have the lsptest repository cloned

### **2. Compile the LSP Helper**
Run the following command in the `lsptest` directory:
```bash
dart compile exe bin/lsp_helper.dart
```
This creates an executable (`lsp_helper.exe` on Windows, or `lsp_helper` on Linux/Mac) in the `bin` folder.

### **3. Find Your Dart Path (Optional)**
The wrapper can auto-detect Dart, but you may want to get the explicit path:
```bash
which dart          # On Linux/Mac
where dart.bat      # On Windows
```

### **4. Configure Zed Settings**
Open Zed's settings file (`settings.json`):
- **Mac/Linux**: `~/.config/zed/settings.json`
- **Windows**: `%APPDATA%\Zed\settings.json`

Add the LSP configuration for Dart:
```json
"lsp": {
  "dart": {
    "binary": {
      "path": "<path-to-lsp_helper-executable>",
      "arguments": ["<optional-dart-full-path>"]
    }
  }
}
```

**Example:**
```json
"lsp": {
  "dart": {
    "binary": {
      "path": "/home/user/lsptest/bin/lsp_helper",
      "arguments": []
    }
  }
}
```

### **5. Restart Zed**
Close and reopen Zed to load the new LSP configuration.

### **6. Test Autocomplete**
- Open or create a Dart file (`.dart`)
- In your Dart code, start typing something like:
  ```dart
  var str = "";
  str.
  ```
- After typing the `.`, the autocomplete menu should appear with suggestions

### **7. Verify It's Working**
- The autocomplete should trigger on `.` (dot)
- You should see methods and properties available on the object
- If autocomplete appears, the fix is working!

### **Troubleshooting**
- **If nothing happens**: Check Zed's LSP logs (help menu → toggle developer console)
- **Executable not found**: Verify the path to `lsp_helper` is correct
- **Still no autocomplete**: The Dart LSP may need to be restarted; try closing/opening the file


**Summary:** This repository documents an issue where Dart autocomplete doesn't trigger on the `.` character in the Zed editor, analyzes the root cause (missing `triggerCharacters` in the LSP response), and includes a Dart wrapper as a proof-of-concept solution.