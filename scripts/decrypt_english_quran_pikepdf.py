import pikepdf

src = r"C:\Users\moham\quran\assets\assets\The_Holy_Quran_English.pdf"
dst = r"C:\Users\moham\quran\assets\assets\The_Holy_Quran_English_unlocked.pdf"

# Try common empty/user passwords first.
passwords = ["", "user", "owner", "1234", "quran"]
last_err = None
for pw in passwords:
    try:
        with pikepdf.open(src, password=pw) as pdf:
            pdf.save(dst)
            print(f"UNLOCKED_OK password='{pw}' -> {dst}")
            raise SystemExit(0)
    except Exception as exc:
        last_err = exc

print(f"UNLOCK_FAILED: {last_err}")
raise SystemExit(1)
