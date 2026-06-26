from pathlib import Path
import sys
from pypdf import PdfReader, PdfWriter


def rotate_pdf(input_path: str, angle: int) -> Path:
    src = Path(input_path)
    if not src.exists():
        raise FileNotFoundError(f"File not found: {src}")

    if src.suffix.lower() != ".pdf":
        raise ValueError(f"Not a PDF file: {src}")

    angle_tag = str(angle).replace("-", "m")
    dst = src.with_name(f"{src.stem}.rot{angle_tag}{src.suffix}")

    reader = PdfReader(str(src))
    writer = PdfWriter()

    for page in reader.pages:
        page.rotate(angle)
        writer.add_page(page)

    with open(dst, "wb") as f:
        writer.write(f)

    return dst


def main():
    if len(sys.argv) < 3:
        print("Usage: py rotatepdf.py <angle> <file1.pdf> [file2.pdf ...]")
        print("Example: py rotatepdf.py 90 file.pdf")
        sys.exit(1)

    angle = int(sys.argv[1])
    failed = False

    for arg in sys.argv[2:]:
        try:
            out = rotate_pdf(arg, angle)
            print(f"Created: {out}")
        except Exception as e:
            failed = True
            print(f"FAILED: {arg}")
            print(f"  {e}")

    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()