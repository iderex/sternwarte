# sternwarte

Given one sky position, the tool fetches the epoch photometry that already exists for it across ZTF, ASAS-SN, Gaia, Pan-STARRS, SDSS Stripe 82, ATLAS and TESS, and returns a single cross-calibrated time series rather than seven downloads in seven photometric systems. The join is the product: one survey gives five to ten years of baseline, the combination gives twenty-five and more.

Planning happens on the issue tracker first. Every decision that shapes
the architecture is written down there with its reasons before the code
that depends on it exists.

See [NOTICE.md](NOTICE.md) for the intended-use notice.

## License

AGPL-3.0, copyright 2026 Nils Lehnen.

The full text is in [LICENSE](LICENSE).
