
import sys, os, cv2, dlib

def ensure_dir(p):
    os.makedirs(p, exist_ok=True)

def extract_and_process_video_frames(video_path, output_folder,
                                     num_frames_to_extract=20,
                                     padding=30,
                                     strict_legacy_naming=False):
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[ERROR] cannot open {video_path}", file=sys.stderr)
        return 0

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    start_frame = round(total_frames / 40)
    if total_frames > start_frame + num_frames_to_extract:
        step = total_frames // (num_frames_to_extract)
    else:
        step = 1

    current_frame = start_frame
    extracted = 0

    detector = dlib.get_frontal_face_detector()
    ensure_dir(output_folder)

    while extracted < num_frames_to_extract and current_frame < total_frames:
        cap.set(cv2.CAP_PROP_POS_FRAMES, current_frame)
        ret, frame = cap.read()
        if not ret or frame is None:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = detector(gray)

        if len(faces) > 0:
            i = extracted  # 0-based
            for fi, face in enumerate(faces):
                x1 = max(0, face.left()  - padding)
                y1 = max(0, face.top()   - padding)
                x2 = min(frame.shape[1], face.right() + padding)
                y2 = min(frame.shape[0], face.bottom()+ padding)

                crop = frame[y1:y2, x1:x2]
                if crop.size == 0:
                    continue
                crop = cv2.resize(crop, (300, 300), interpolation=cv2.INTER_CUBIC)

                if strict_legacy_naming:
                    fn = os.path.join(output_folder, f"cropped_frame_{i}.png")
                else:
                    suffix = "" if fi == 0 else f"_{fi}"
                    fn = os.path.join(output_folder, f"cropped_frame_{i}{suffix}.png")

                cv2.imwrite(fn, crop)

        extracted += 1
        current_frame += step

    cap.release()
    return extracted

def main():
    if len(sys.argv) < 4:
        print(" <real_video> <fake_video> <out_dir> "
              "[n_frames=20] [padding=30] [strict_legacy_naming=0]",
              file=sys.stderr)
        sys.exit(2)

    real_video = sys.argv[1]
    fake_video = sys.argv[2]
    out_dir    = sys.argv[3]
    n_frames   = int(sys.argv[4]) if len(sys.argv) > 4 else 20
    padding    = int(sys.argv[5]) if len(sys.argv) > 5 else 30
    strict     = int(sys.argv[6]) if len(sys.argv) > 6 else 0
    strict     = (strict != 0)

    real_dir = os.path.join(out_dir, "real_crops")
    fake_dir = os.path.join(out_dir, "fake_crops")
    ensure_dir(real_dir); ensure_dir(fake_dir)

    sr = extract_and_process_video_frames(real_video, real_dir, n_frames, padding, strict)
    sf = extract_and_process_video_frames(fake_video, fake_dir, n_frames, padding, strict)
    print(f"[INFO] saved (frame-iterations) real={sr} fake={sf}")

if __name__ == "__main__":
    main()
