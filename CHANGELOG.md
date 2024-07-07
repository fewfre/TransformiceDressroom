## V1.29d - 27 June 2024
- Updated poses file
	- Fixed bug with sit animation foot disappearing
	- Fixed bug with gift animation eye disappearing
	- Fixed bug with zelda animation eye disappearing
- Reordered some poses so that `PreInvoc`/`Invoc` and `StatiqueBalai`/`CourseBalai` are now paired on the same line as it's partner
- Fixed `Sleep` and `Plumes` pose buttons not having the image properly centered
- [Misc] Converted changelog into markdown
- [Misc] (7 Jul) Added some analytics (via tracking pixel) for user language + whether using app or browser


## V1.29c - 27 June 2024
- [Code] Rewrote grid button logic such that only 1 grid is needed for additional buttons in same cell (such as delete button)
- [Code] Color Finder cropping code made a tiny bit clearer
- Added ability to favorite items and have them appear above the items grid


## V1.29b - 21 June 2024
- Added an animation control widget that allows for finer control over the animation of the puppet
- The following poses now have a more helpful frame shown on poses tab pane:
	- Kiss, Neige, Clap, Rondoudou, Attaque, Hi5_1, Hi5_2
- Heart from kiss animation no longer flashes on/off when animation paused
- [Bug] Fixed "copy to clipboard" button being broken due to change from animation control widget
- [Code] Cleaned up `Toolbox` and made it `Event` driven
- Replaced bottom left github button/version text with a new button to a new "About" screen (where aforementioned content has been moved)
	- Added a discord link button on new About screen
- Clicking an item on the "Worn Items" pane will now open the item in the Color Picker (if it's customizable)
- [Bug] If you pause an animation and change an item it no longer resets pause to default frame (this was happening before animation update too, long standing bug ;_;)
- [Bug] Fixed lag caused by a recent update
- Optimized Outfit Manager pane so list isn't fully re-rendered on outfit adding, deleting, or list reversing.
- [Code] `ShopInfobar` rewrite (and renamed to `Infobar`)
	- Moved grid management logic to it's own component
	- Grid management button groups can now be hidden individually, instead of all or nothing
	- Hovering over item preview on infobar now properly shows a pointer cursor (to make it more obvious it's clickable)
- Removed randomize and arrow buttons from toolbar item filter item selection screen
- Updated back button arrow and the red x (used for closing item filter banner) to have a larger hit area
- [Code] Rewrote `RoundedRectangle` to have width/height as normal params
- [Code] Renamed `TextBase` to `TextTranslated`, and then a new `TextBase` made (which `TextTranslated` inherits from)
- [Bug] "X" overlay on toolbar preview had a small bug prevent it from showing


## V1.29 - 19 June 2024
- Color locks are now remembered on a per-item basis until you close the app, hit "Defaults" button on color picker, or trash entire outfit
- [Code] `BitmapLoaderManager` updated to correctly use local images when not run in app
- [Code] Rewrote the `TabPane` (now `SidePane`) and scrollbox logic
- [Bug] Fixed previous `TabPane` change preventing swatches being clicked on color picker


## V1.28b - 4 May 2024
- Added a "pastebin" feature that grabs an item filter code from a pastebin. Ex: `ITEMFILTER?pastebin=i7b5v800`
- When item filtering is on, the filter tab is no longer shown and instead a banner appears over share code input
- When filter tab is on, you are now always in selection mode - preview button now puts you in a different mode
- New filter icon added for button in "Other" pane
- In filter selection mode, a giant filter icon is shown instead of the mouse to make it clearer what mode you are in
- Text added for filter mode stuff
- Filters tab "x" button split into 2 - one for closing selection mode, and the other for trashing filters
- Finally moved White "X" icon to interface.swc instead of programmatically drawing it
- Fixed issue with lists getting reversed again every time they are redrawn (causing it to flip between reversed and not reversed)
- (23 May) Split up asset loader code a bit
- (31 May) +rs / српски / Serbian


## V1.28 - 28 April 2024
- Added first draft of item filtering share code logic.
	- Button for making a new one currently invisible on "Other" pane


## V1.27c - 16 December 2023
- Ice cheese added
- Cheese now has has the row to itself, with wand/shield moved to it's own row
- Outfits button moved to below toolbar for easier access / to match shaman items app
- (21 Dec) Small tweak to "back" behavior on "outfits" pane
- (18 Jan) TFM share codes update to include missing values
- (15 Feb) Added new cheese + split cheese into a separate swc file
- (19 Mar 2024) Fixed contact using eyelash as a fallback attachment


## V1.27b - 6 December 2023
- Fixed bug causing color history to stay in delete mode when it shouldn't.
- Fixed layering bug with slots/accessories in child elements
- Tweaked code to support items with embedded scripts that remove/replace mouse parts (Tail 69)
- Rewrote `AssetManager` to be more inline with in-game (to fix another issue with Tail 69)
- [Code] Added bitmap lazy loading
- Add the ability to set the flag used in flag animation
	- Fewf style share codes now include flag code if there is one
- Fixed position/layer bug with Tail 67 (these tails hate me)
- "Defaults" button on color picker now respects locks
- [Code] Made `GameAssets.init` asynchronous to prevent a bit of the freeze-up during app initialization phase
- [Bug] Fixed share code success/invalid message not being correct (2 bugs in 1!)


## V1.27 - 2 November 2023
- Added stinky cheese back item
- Mouse & color finder drag code tweaked
	- Letting go of mouse outside of drag area no longer keeps it in drag mode
	- The spot you grabbed can no longer leave the "safe area" / drag zone
	- Changing the scale when the center of the mouse / item is outside the safe zone will clamp the center into the safe area to prevent it being scaled down to where it can no longer be clicked.


## V1.26 - 8 October 2023
- Added support for "disable skills" shaman mode
- Added "pumpkin" as a back item to "Other" tab
- [Bug] Fixed default skin ear using wrong pattern
- Small code cleanup with default skin - now properly stored in swc, and fixed reason why it wasn't originally (compiler removing it due to no direct references)


## V1.25d - 8 September 2023
- Updated `slot_` rendering to new code


## V1.25c - 24 June 2023
- Fixed color preview bug with new hair item (caused by children on sub layer being ignored)
- Fixed issue preventing saving on android


## V1.25b - 2 May 2023
- Allow traversing color swatches using up/down arrow keys
- A list of worn items can be seen by double clicking the main mouse image


## V1.25 - 27 April 2023
- Added support for new tattoo item category


## V1.24b - 9 April 2023
- Fixed bug with item layering (again)
- gif changed to no bg (even with the outside border weirdness it creates)


## V1.24 - 8 April 2023
- Images can now be downloaded as gifs
	- This happens automatically when downloading your mouse while the animation is on
- Removed old frame-by-frame code
- Error window added
- Added `.webp` animation download option


## V1.23i - 8 April 2023
- Item layering fixed
- Updated `slot_` code to support new `first_` option
- Overhauled `Pose` to match in-game logic much more closely


## V1.23h - 28 February 2023
- [Bug] Clicking scale slider will no longer prevent left/right arrow keys from traversing item grid.
- Scale slider code polished - track hitbox increased & clicking anywhere on track now starts drag.


## V1.23g - 17 February 2023
- Added support for new `behind_` slot logic
- Up/Down arrow keys now traverse the grids vertically


## V1.23f - 10 February 2023
- Trashcan button will now reset pane lock state + reset all item customizations to default. (suggestion: QTAngel)
- [Bug] Pasting a share code / selecting an outfit now properly customizes the List buttons to match the colors.
- [Bug] Eye:31 now properly handles faulty MC id for first color
- Code rewrite / cleanup
	- Updated/polished `GameAssets` color functions to be less awful
	- `shamanMode`/`shamanColor` moved from `GameAssets` onto `Character` so all character info is in the same place
	- `PNGEncoder` updated to match source
	- `com.piterwilson` lib source polished + moved `com.paulcoyle`'s `AngularColour` into it


## V1.23e - 30 January 2023
- Fixed bug when showing outfits that forces all copies of the same item to display the same color
	- Also fixed current shaman mode being applied to all outfits
- Fixed bug that doesn't show existing item customization on infobar when opening color picker
- Some code cleanup / rework
	- Moved shop item pane code from `World` into `ShopCategoryPane`
	- Removed some old DeadMaze gender code
	- `SHAMAN_MODE` renamed to `ShamanMode` and given proper enum typing
	- `ITEM` renamed to `ItemType` and given proper enum typing
	- `ImgurApi` moved to `com.fewfre.utils`
	- Removed `SKIN_COLOR` from `ItemType` as it's no longer useful and is instead awkward to work around
		- replaced by `isSkinColor` property on `SkinData`
	- `Grid` revamped and moved to `com.fewfre.display`
	- Some components in `ui` moved to new `ui.common` folder
	- Small `RoundedRectangle` revamp
	- Multiple `_drawLine` function replaced with new `GameAssets.createHorizontalRule()`


## V1.23d - 30 January 2023
- Fixed color swatches not formatting number with 0s
	- Reworked color picker code a bit to finally fix this issue
		- Moved `ColorSwatch` and `ColorPickerTab` into the same folder
		- Moved color history into it's own component
- The black handle above color picker updated to be white to be more visible


## V1.23c - 28 January 2023
- Outfit Manager added (button to access it on "Other" tab pane) (suggestion: Icylina#0000)
- Clicking infobar item image container now closes the screen and removes the item like it normally does on other screens (suggestion: Barberserk)
- Item image container now hidden on shaman color picker
- Copy button added to toolbox (app only, due to AIR requirements)
- Resource update system redone to be more user friendly - it is now run from `/resources/update/` instead of `/resources/update.php`


## V1.23b - 25 January 2023
- TabPane infobar redesigned
- Added left/right arrows to infobar that do same as keyboard arrow keys (mobile support)
- Hovering over infobar image will now show an 'x' to better signal that clicking it will remove the item
- Fixed clicking infobar item image not always removing it
- Using arrows / randomize button to select an item off-screen will now scroll the button into view
- Tweaked icon representing no selected item


## V1.23 - 24 January 2023
- Fixed bug with slot colors not being properly counted, and showing up as non-customizable
- Removing `username_lookup_url` in the config will now hide the feature in-app
	- Since this would leave config tab very empty, share code paste input moved to old location in the above case.
- Removed duplicate mouth item (hardcoded)
- Added ability to traverse through item buttons using left/right arrow key (suggestion by Barberserk)
- Item type tabs now sorted in same order as in-game


## V1.22b - 17 October 2022
- Hovering over color swatch square on color picker will temporarily invert the corresponding color on the target item until hovering is stopped
- Tweaked top bar on shop tab panes to have a larger item preview size


## V1.22 - 2 October 2022
- Added randomize color button to item color picker page
- Undo button added on color picker - clicking it will show colors previously used on the specific color swatch for that specific item.
- Updated color buttons to look nicer
- Recent colors list design reworked and moved to it's own class
- Recent colors now also shown on color finder
- Color finder now supports scaling image & dragging it around
- Files can now be uploaded from the user's computer into the color finder (request by Milinili)
- Manually selecting a language will now cause the app to remember it the next time it is opened (request by Zelenpixel#9767)
- Items now listed in reverse order by default, and a button has been added to reverse the order of the list
- Big thanks to QTAngel & Barberserk for suggestions and testing out my changes!

- Added support for new "slot_" behavior on items
- Tweaked shaman wings to match exact in-game values
- Back button added when in downloadable app
- Recent colors now remembered across dressrooms in the app
- Increased max costumes to check constant + made the checking more efficient


## V1.21 - 21 January 2022
- Blacklist feature added for username lookup
- Tweaked color picker
	- 'Recent colors' can now be removed
	- Pasted/typed colors are now detected
	- Clicking on empty area below swatch or hitting 'enter' when typing in a swatch will now save the the last recent color as well
	- Fixed various small bugs on color picker
- Added a button for saving an image of just a mouse head


## V1.20 - 19 December 2021
- Added Config tab
- Moved share cost posting input into config tab
- Added username lookup to config tab
- Color picker now remembers up to last 9 recent color changes and adds buttons to bottom of picker


## V1.19 - 1 May 2021
- Randomize button icon changed to dice
- Lock icon on infobar now disables randomize button to make it's purpose clearer
- Shaman color option on config pane now has quick options for the 2 default colors
- Fixed bug with eye items not appearing on some poses


## V1.18 - 4 February 2021
- Adding support for official Transformice /dressing share codes
	- App can accept either type of code
	- App lists both types of share codes


## V1.17 - 4 January 2020
- Added support for being externally loaded by AIR app


## V1.16 - 7 September 2019
- Added ability to play animation frame-by-frame for exporting (NOT included in live build, only meant for special circumstances) - must be turned on in code via ConstantsApp.ANIMATION_FRAME_BY_FRAME
- Fixed bug with default fur paw coloring while sitting
- Fixed bug with sit animation having foot disappear (WARNING: fixing involved editing the poses.swf for simplicity; updating that file may cause issues)


## V1.15 - 1 January 2019
- Updating share links to use ";" instead of "," to better support atelier801 forum


## V1.14c - 12 December 2018
- Fixed bug with hand item appearing twice (in both hands) while dancing


## V1.14b - 16 July 2018
- Translation ro updated by Sky
- Small lv translation update


## V1.14 - 7 June 2018
- [Bug] When a hand item was downloaded, it had the name as "hand" instead of "hands" (as it is in-game)
- [Bug] When the trash icon is removed, "other" items and shaman mode are now removed as well.


## V1.13 - 7 June 2018
- Adding "hand" items
- Code cleanup / validation for "strict" compilation


## V1.12 - 6 June 2018
- Async loading added, that preserves load order.
- Ability to translate pose names as per a request (added prior to this version, but never committed)


## V1.11 - 10 February 2018
- Added a "trash" button to reset look back to default
- Randomized look button now has a chance to not use an item for each category (fairly high: 35%; pose: 50%)
- Increased max zoom size: https://github.com/fewfre/TransformiceDressroom/issues/5
- Added some cache breaking


## V1.10 - 15 December 2017
- Increased color swatches to 10 so there are enough for all items.
- Item resource swfs now loaded based on config.json
- Renamed "Costumes" to "GameAssets" and changed it from a singleton to a static class.


## V1.9 - 30 July 2017
- Download image button changed to floppy disk


## V1.8 - 25 July 2017
- Added various translations from http://atelier801.com/topic?f=6&t=853111
	-ar, de, fr, hr, hu, lv, pl, pt, ro, ru, se, tr
- Tweaked TextBase to center multiline text
- update.php now loops through the swf names rather than hardcoding each link


## V1.7 - 15 July 2017
- Imgur upload option added.
- Resources are no longer cached.


## V1.6 - 13 July 2017
- Share link feature added / finished.
- Color finder feature added for items.
- [bug] If you selected an item + colored it, selected something else, and then selected it again, the infobar image showed the default image.
- [bug] Downloading a colored image (vs whole mouse) didn't save it colored.
- Default fur now has a coloring wheel option (to simulate Funcorp ability)


## V1.5 - 8 July 2017
- Added app info on bottom left
	- Moved github button from Toolbox
	- Now display app's version (using a new "version" i18n string)
	- Now display translator's name (if app not using "en" and not blank) (using a new "translated_by" i18n string)
- Bug: ConstantsApp.VERSION is now stored as a string.
- Download button on Toolbox is now bigger (to show importance)
- ShopInfoBar buttons tweaked
	- Refresh button is now smaller and to the right of download button
	- Added a "lock" button to prevent randomizing a specific category (inspired by micetigri Nekodancer generator)
	- If a button doesn't exist, there is no longer a blank space on the right.
	- Download button is now smaller (so as to not be bigger than main download button).
- AssetManager now stores the loaded ApplicationDomains instead of the returned content as a movieclip
- AssetManager now loads data into currentDomain if "useCurrentDomain" is used for that swf
- Moved UI assets into a separate swf
- Fewf class now keeps track of Stage, and has a MovieClip called "dispatcher" for global events.
- I18n & TextBase updated to allow for changing language during runtime.
- You can now change language during run-time


## V1.4 - 3 July 2017
- Forcing items to fit within their containers, and smaller items are now scaled up.
- Moved DisplayObject image saving code to FewfDisplayUtils (was in "Costumes").
- Moved most of the contents of "Main" into new class "World" to separate loading and app logic.
- Fixed "contacts" layering bug (they where appearing over "eye" items).
- Updated ColorSwatch to be a little more user friendly (as per feedback by RichàrdIDK on Disqus)
	- Clicking a textbox now counts as selecting the swatch.
	- Typing in a hex code will update the value without the need to press enter first.


## V1.3 - 4 June 2017
- Renaming "dressroom" folder to "app"
- Moving Main from ./src to ./src/app
- Made Costumes a singleton, made Main.costumes non-static and private, and replace all instances of it to Costumes.instance.
- Renamed some root level files to more common naming; changelog -> CHANGELOG and todo.txt -> TODO


## V1.2 - 1 June 2017
- Added contact lenses support


## V1.1 - 14 January 2017
- Updated BrowserMouseWheelPrevention to fix bug in Chrome


## V1.0 - 7 January 2017
- Using version numbers
- Added localization support.
	- Uses json file.
	- AssetManager changed to handle loading json files
	- Added an I18n class for localization support
	- TextBase now requires use of localization.
- Added TextBase to everywhere that was using hardcoded text.
- Added Fewf class that holds instances of AssetManager and I18n for easy accessing across classes.


## Pre V1
- had all the basic features in
