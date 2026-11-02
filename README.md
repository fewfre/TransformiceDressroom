# TransformiceDressroom
Transformice dressingroom, with options to dress, color, and tweak your character for high-detail images!

View it live at: http://projects.fewfre.com/a801/transformice/dressroom/

Originally based on cheese.formice dressroom by Baffler

## Run and Debug

This project is a Flash Player SWF project, with two ways to build it, both of which output `dressroom.swf` based on the same `src/app/Main.as` starting point in the code.

### FLA
The original way to build this project is my installing Adobe CS6 and running `dressroom.fla` - other versions might work, but what I used (libraries might be in different locations/missing on other versions). Note that using CS6 will output an older flash version than the method below or possible using a newer flash professional version would allow, but it (as of time of writing) it should still be fully functional.

### VSCode / `asconfig.json`
The other way to build this is by running `asconfig.json` though another build method; in the case of these instructions VSCode, but could probably use others.

For this project it's assumed some default flash/CS6 libraries and programs are at the locations installing CS6 would put them at, but technically you could just get those files/libraries some other way and update the path in `asconfig.json` and the `.vscode` files; but I won't be walking through that.

1. Install the ActionScript & MXML (`bowlerhatllc.vscode-as3mxml`) and SWF Debugger (`bowlerhatllc.vscode-swf-debug`) extensions for VS Code, and install the Flash Player standalone debugger.
2. If the debugger is installed in a different location, update `runtimeExecutable` in `.vscode/launch.json` to point to `FlashPlayerDebugger.exe`.
3. Trust this workspace for local-file access. Add the absolute workspace folder path as a line in `%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\FlashDevelop.cfg` (create the file if needed), then restart Flash Player Debugger. This lets the SWF load its local `resources` files and avoids Flash Player's local-file sandbox errors.
	* This step is optional if you don't care about testing/running locally; would just require you run it on a server or load it via an AIR app
4. In VS Code, choose **Build and Debug Dressroom SWF** in Run and Debug and press `F5`. The launch configuration runs the debug compile task first, then opens `dressroom.swf` in Flash Player Debugger.
5. The **Tail Flash Player trace log** task starts automatically when the workspace opens and shows `trace()` output in VS Code's "Debug Console" panel (typicall the same one terminal/output/etc tabs are on). You can also start it from **Terminal → Run Task**. Flash Player writes traces to `%APPDATA%\Macromedia\Flash Player\Logs\flashlog.txt`; `mm.cfg` must include `TraceOutputFileEnable=1` for this to work.