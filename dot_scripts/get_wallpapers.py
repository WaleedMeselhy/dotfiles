import shutil
import os

import requests
from bs4 import BeautifulSoup

# USAGE: Add all the galleries that you want to be scraped in the list below
roots = [
    "https://quotefancy.com/motivational-quotes",
    "https://quotefancy.com/inspirational-entrepreneurship-quotes",
    "https://quotefancy.com/startup-quotes",
]
from pathlib import Path

home = str(Path.home())
# The root directory
root_dir = home + "/quotefancy"
if not os.path.exists(root_dir):
    os.mkdir(root_dir)

for root in roots:
    directory = os.path.join(root_dir, root.split("/")[-1])
    if not os.path.exists(directory):
        os.mkdir(directory)
    response = requests.get(root)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text)
        hyperlinks = soup.find_all("a")
        img_links = []
        for link in hyperlinks:
            img = link.find("img")
            if img and img.get("data-original"):
                img_links.append(img["data-original"])
        if img_links:
            count = 0
            for linky in img_links:
                name = linky.split("/")[-1]
                res = requests.get(linky, stream=True)
                path = os.path.join(directory, name)
                with open(path, "wb") as out_file:
                    shutil.copyfileobj(res.raw, out_file)
                    count += 1
                    print(count)
                del res
