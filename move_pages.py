import os
import glob
import shutil

features = ['auth', 'booking', 'catalog', 'gym', 'home', 'membership', 'notification', 'profile']

for feature in features:
    pages_dir = f"lib/features/{feature}/presentation/pages"
    screens_dir = f"lib/features/{feature}/presentation/screens"
    
    if os.path.exists(pages_dir):
        # Move all files from pages to screens
        for item in os.listdir(pages_dir):
            src = os.path.join(pages_dir, item)
            dst = os.path.join(screens_dir, item)
            shutil.move(src, dst)
        # remove pages_dir
        os.rmdir(pages_dir)
        print(f"Moved pages to screens in {feature}")

# Move explore
if os.path.exists("lib/screens/explore"):
    for item in os.listdir("lib/screens/explore"):
        src = os.path.join("lib/screens/explore", item)
        dst = os.path.join("lib/features/explore/presentation/screens", item)
        shutil.move(src, dst)
    os.rmdir("lib/screens/explore")
    print("Moved explore screen")
    
if os.path.exists("lib/screens"):
    if not os.listdir("lib/screens"):
        os.rmdir("lib/screens")

# Move membership_page.dart that was directly in presentation
if os.path.exists("lib/features/membership/presentation/membership_page.dart"):
    shutil.move("lib/features/membership/presentation/membership_page.dart", "lib/features/membership/presentation/screens/membership_page.dart")
