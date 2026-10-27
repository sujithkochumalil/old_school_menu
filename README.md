# Old School Tea: QR Menu (Flutter Web)

A customer scans the QR on the table, the phone opens a web page, and the full menu shows. They don't need to install an app.

```
https://<your-project>.web.app/r/old-school-tea?t=5
                                  └── menu id ──┘ └ table no.
```

**What the screen has**
- A dark brown header card with the shop name, an "Open now · Closes 10 PM" status, a table badge, and the address
- A sticky bar with search, a **Veg** filter, and category chips that highlight as you scroll. Tapping a chip jumps to that section.
- A **Popular right now** carousel that shows every item tagged `Bestseller`
- Rounded item cards with the veg/non-veg mark, a badge, and the price. Sold-out items are greyed out.
- A bottom sheet with item details when an item is tapped
- A coffee-cup loader while the app downloads, a "Menu not found" page for wrong QRs, and an error page with retry
- On laptops the page stays at phone width, centred

The menu lives in one JSON file (`assets/menus/old-school-tea.json`), so you don't need a backend. To change a price, edit the file and deploy again.

---

## Project files

```
old_school_menu/
├── pubspec.yaml
├── firebase.json                  ← hosting config (rewrites + no-cache)
├── assets/menus/
│   └── old-school-tea.json        ← THE MENU (edit this)
├── web/
│   ├── index.html                 ← loader + meta tags
│   └── flutter_bootstrap.js       ← removes the loader when the app starts
└── lib/
    ├── main.dart                  ← reads /r/<id>?t=<table> from the URL
    ├── theme/
    │   ├── app_colors.dart        ← all colours
    │   └── app_theme.dart         ← textStyle(), titleStyle(), ThemeData
    ├── models/menu.dart           ← Restaurant, MenuCategory, MenuItem
    ├── services/menu_service.dart ← loads the JSON (swap this for Firestore later)
    ├── screens/
    │   ├── menu_screen.dart       ← main page, scroll + chips logic
    │   └── not_found_screen.dart
    └── widgets/
        ├── menu_header.dart       ← brown header card
        ├── category_bar.dart      ← search + veg + chips (sticky)
        ├── item_tile.dart         ← ItemTile + PopularCard
        ├── item_sheet.dart        ← bottom sheet
        ├── item_thumb.dart        ← image or icon placeholder, category icons
        └── badges.dart            ← VegMark, TagPill
```

Packages: `google_fonts` (Plus Jakarta Sans + Fraunces) and `url_launcher` (for the Call button). `flutter_web_plugins` comes with the Flutter SDK.

---

## Step 0: Before you start

1. **Flutter 3.22 or newer.** Check with:
   ```
   flutter --version
   flutter devices
   ```
   Chrome should appear in the device list.
2. **Node.js LTS**, from nodejs.org. You only need it for the Firebase CLI.
3. **A Google account.** Firebase's free Spark plan covers Hosting, and you don't need a card.

---

## Step 1: Create the project

```
flutter create --platforms web old_school_menu
cd old_school_menu
```

## Step 2: Copy the files in

From this folder, copy these into the new project and **replace** files that already exist:

| Copy | What happens |
|---|---|
| `pubspec.yaml` | replaces the generated one |
| `firebase.json` | new file in the project root |
| `lib/` (whole folder) | replaces `lib/main.dart` and adds the rest |
| `assets/` (whole folder) | new folder in the project root |
| `web/index.html` | replaces the generated one |
| `web/flutter_bootstrap.js` | new file next to index.html |

Then **delete `test/widget_test.dart`**. It refers to the counter app's `MyApp` and will show errors.

## Step 3: Get packages

```
flutter pub get
```

If the versions in pubspec are too old for your Flutter, run `flutter pub upgrade --major-versions`.

## Step 4: Run it on your PC

```
flutter run -d chrome --web-port 8080
```

Try these URLs in that Chrome window:

| URL | You should see |
|---|---|
| `http://localhost:8080/` | Old School Tea menu (the default) |
| `http://localhost:8080/r/old-school-tea?t=5` | Same menu with a **Table 5** badge |
| `http://localhost:8080/r/abc` | "Menu not found" |

To see it at phone size, press `Ctrl + Shift + M` in Chrome DevTools and pick a phone.
After you change code or JSON, press `R` (capital R, hot restart) in the terminal.

## Step 5: Test on your real phone (same Wi-Fi)

1. Find your PC's IP address: run `ipconfig` and look at the IPv4 Address, for example `192.168.1.5`.
2. Run:
   ```
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   ```
3. On the phone, open `http://192.168.1.5:8080/r/old-school-tea?t=5`
4. If Windows Firewall asks, allow it on **Private networks**.

This is a debug build, so it loads slowly on the phone. The release build in Step 7 is much faster.

---

## Step 6: Put the real menu in

Open `assets/menus/old-school-tea.json`.

> ⚠️ **The prices, descriptions and badges in this file are samples.** Zomato's page couldn't be opened, so the item names came from public listings of Old School Tea outlets. Check every item and price against the outlet's Zomato menu or printed menu, and remove anything they don't sell.

**Shop fields**

| Field | Example | Notes |
|---|---|---|
| `id` | `"old-school-tea"` | must match the file name |
| `name`, `tagline` | | shown in the header |
| `address` | `"MC Road, Perumbavoor"` | shows a pill in the header and text in the footer. Leave `""` to hide. |
| `phone` | `"+919876543210"` | shows a **Call** button. Leave `""` to hide. |
| `opens`, `closes` | `"07:00"`, `"22:00"` | 24-hour format. Drives the Open/Closed pill. Leave `""` to hide it. |
| `logo` | `"assets/images/logo.png"` | Leave `""` for the cup icon. Use their logo only if the outlet gives it to you. |

**Category fields**: `id` (unique), `name`, and `icon`. The icon can be `tea`, `special`, `coffee`, `cold` or `snack`. Anything else shows a menu icon.

**Item fields**

```json
{ "id": "hazelnut-latte", "name": "Hazelnut Latte", "desc": "Espresso, steamed milk and hazelnut",
  "price": 70, "veg": true, "tag": "Bestseller", "available": true, "image": "" }
```

- `id`: unique, lowercase with dashes
- `tag`: `"Bestseller"` puts the item in **Popular right now**. Any other text (like `"New"`) only shows a small badge. Use `""` or leave the field out for no badge.
- `available: false` greys the item out and shows **Sold out**
- `image`: a full `https://…` link or `assets/images/xyz.jpg`. If empty, the coloured icon tile shows.

**Adding photos**
1. Create the folder `assets/images/` and put the photos in it. Square photos around 600×600 work best. Compress each to under 150 KB, for example at squoosh.app.
2. In `pubspec.yaml`, add a line under `assets:`:
   ```yaml
   assets:
     - assets/menus/
     - assets/images/
   ```
3. Use `"image": "assets/images/hazelnut-latte.jpg"` in the JSON.

**Before saving, check the JSON is valid.** VS Code underlines mistakes in red. A missing comma or quote shows the "Something went wrong" page.

**Changing the look**: colours are in `lib/theme/app_colors.dart`, and fonts are in `lib/theme/app_theme.dart`.

**More than one outlet**: copy the JSON to `assets/menus/old-school-tea-perumbavoor.json` and set `"id": "old-school-tea-perumbavoor"`. Its URL is `/r/old-school-tea-perumbavoor`. Ids can only use lowercase letters, numbers and `-`.

---

## Step 7: Build for release

```
flutter build web --release
```

The site is written to `build/web/`. To check it locally with real speed:

```
npx serve -s build/web -l 5000
```

Then open `http://localhost:5000/r/old-school-tea?t=2`.

## Step 8: Put it online (Firebase Hosting, free)

1. Go to **console.firebase.google.com**, click **Create a project**, and give it a name.
   The project ID becomes your link (`https://<project-id>.web.app`), so edit it to something clean like `oldschooltea-menu`. You can turn Google Analytics off. Then click Create.
2. Install the Firebase CLI:
   ```
   npm install -g firebase-tools
   ```
   If PowerShell says *running scripts is disabled*, run this once:
   `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
3. Log in:
   ```
   firebase login
   ```
4. In the project folder, run:
   ```
   firebase init hosting
   ```
   Answer the questions like this:
   - *Please select an option* → **Use an existing project**, then pick yours
   - *What do you want to use as your public directory?* → `build/web`
   - *Configure as a single-page app?* → **Yes**
   - *Set up automatic builds and deploys with GitHub?* → **No**
   - *File build/web/index.html already exists. Overwrite?* → **No** ← important
5. `firebase init` overwrites `firebase.json`, so copy the `firebase.json` from this folder back in. Keep the new `.firebaserc` file it created.
6. Deploy:
   ```
   firebase deploy --only hosting
   ```
7. Open `https://<project-id>.web.app/r/old-school-tea?t=1` on your phone using **mobile data**.

## Step 9: Make the QR codes

- Give each table its own link: `…/r/old-school-tea?t=1`, `?t=2`, `?t=3` and so on. For the counter, use the link without `?t=`.
- **The easy way**: open the link in Chrome on your PC, then go to ⋮ menu → **Cast, save and share** → **Create QR code** → **Download**.
  If you use a website instead, pick one that makes a **static** QR. "Dynamic" QR sites can expire or show ads.
- **Printing**: make each QR at least 3 × 3 cm, black on white, with a white margin around it. Add text such as **"Scan for menu · Table 5"**.
- Before printing all of them, test with 2–3 different phones: the Android camera, Google Lens and an iPhone camera.
- Laminate them. The QR never needs to change: when the menu changes, you only deploy again.
- Get the outlet owner's go-ahead before the QRs go on their tables, since the page carries their name.

## Step 10: Test checklist (on a phone, on 4G)

- [ ] First load is a few seconds, with the cup loader showing
- [ ] The table badge shows the right number
- [ ] Tapping a chip jumps to its section, and scrolling highlights the right chip
- [ ] Search finds items, and the ✕ clears it
- [ ] The Veg filter hides chicken items
- [ ] Tapping an item opens the bottom sheet
- [ ] Sold-out items are greyed out
- [ ] A wrong link shows "Menu not found"
- [ ] Refreshing on `/r/old-school-tea` doesn't show a 404
- [ ] The Call button works, once you've added a phone number

---

## Updating the menu later

```
(edit assets/menus/old-school-tea.json)
flutter build web --release
firebase deploy --only hosting
```

It takes about a minute. `firebase.json` sends `no-cache`, so customers get the new menu on their next scan.

## Troubleshooting

| Problem | Fix |
|---|---|
| Stuck on "Brewing your menu…" or blank after deploy | You probably answered Yes to *overwrite index.html*. Copy `web/index.html` back, rebuild and deploy. Check the browser console with F12. |
| 404 when refreshing `/r/...` | The `rewrites` block is missing from `firebase.json`. Copy the one from this folder. |
| "Menu not found" for the right link | Make sure the file is named exactly `<id>.json` inside `assets/menus/` and pubspec has `- assets/menus/` under `assets:` (2-space indent). Then do a full restart. |
| "Something went wrong" | There's a mistake in the JSON (missing comma or quote, or text where `price` should be a number). |
| Fonts look plain for a second | `google_fonts` downloads the fonts on first load. That's normal. |
| An old version still shows | Do a hard refresh (Ctrl + Shift + R) or wait a minute. |
| Port already in use | Change `--web-port 8080` to another number, like `8081`. |

---

## Next phase (when you want it)

1. **Firestore**: move the JSON into Firestore and change only `MenuService.load()` to read from it. The UI stays the same. After that, the owner can change prices without a deploy.
2. **Admin page** at `/admin` with a Firebase Auth email login, to edit prices and switch items to sold out.
3. **QR sheet** in admin using `qr_flutter`, to print every table's QR in one go.
4. **Cart + "Order on WhatsApp"**: build a `wa.me` link with the items and the table number. This still needs no backend.
