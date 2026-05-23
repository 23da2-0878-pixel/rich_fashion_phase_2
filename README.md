# Rich Fashion Phase 1

A polished Flutter frontend-only fashion shopping app inspired by the uploaded Rich Fashion Figma/PDF screens and upgraded for a more premium university-submission quality UI.

## Flutter compatibility
- Flutter 3.22+ recommended
- Dart 3.3+

## How to run
```bash
flutter pub get
flutter run
```

## Project structure
```text
lib/
├── core/
│   ├── constants/
│   └── theme/
├── data/
├── models/
├── providers/
├── screens/
│   ├── auth/
│   ├── cart/
│   ├── checkout/
│   ├── home/
│   ├── onboarding/
│   ├── product/
│   ├── profile/
│   ├── search/
│   ├── splash/
│   └── wishlist/
└── widgets/
    ├── common/
    ├── home/
    └── product/
```

## Notes
- This is **Phase 1 only**. No Firebase or backend is used.
- Product, cart, wishlist, search, and profile data are powered by local dummy data with `Provider`.
- All product images and banners are local assets bundled in the project.
- The UI closely follows the uploaded Figma/PDF structure while improving spacing, hierarchy, cards, and interactions for a more realistic app experience.
