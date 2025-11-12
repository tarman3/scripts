#!/usr/bin/env python
# -*- coding: utf-8 -*-

# https://www.makeuseof.com/beautiful-soup-tutorial/

# import io
import requests
# import datetime
from bs4 import BeautifulSoup
from PIL import Image #, ExifTags
import os
# import time
import yt_dlp

# base_url = 'https://apod.nasa.gov/apod'
base_url = 'http://www.star.ucl.ac.uk/~apod/apod'
# url = 'https://apod.nasa.gov/apod/astropix.html'
url = 'http://www.star.ucl.ac.uk/~apod/apod/astropix.html'
out_image = '/home/user/Pictures/apod.jpg'
default_image = '/usr/share/wallpapers/EndeavourOS/contents/images/endeavour_os_simple_wallpaper_dark.png'
tmp_path = '/tmp/apod'
best_quality = True
width_max = 1920
height_max = 1080

# ----------------------------------------------

# Обработка изображения
def processing_image(path, url=None):
    if not os.path.exists(path):
        print(f'\n1-Файл не найден: {path}')
        exit()

    im = Image.open(path)
    w, h = im.size
    print(f'\nwidth={w} height={h}')
    # if w < h:
    if w/h < 0.9:
        # Поворачиваем изображение
        print('\nw < h Rotate image')
        im = im.transpose(Image.ROTATE_270)

    w, h = im.size
    if w > width_max and h > height_max:
        # Уменьшаем изображение
        print(f'\nwidth={w} height={h} Resize image near 1920x1080')
        scale_w = w/width_max
        scale_h = h/height_max
        print(f'scale_x={round(scale_w,3)} scale_y={round(scale_h,3)}')
        scale = min(scale_w, scale_h)
        print(f'Min scale {round(scale,3)}')
        print(f'New image size {round(w/scale)}x{round(h/scale)}')
        im = im.resize((round(w/scale),round(h/scale)), Image.Resampling.BICUBIC)

    im = im.convert('RGB')
    im.info['comment'] = url
    im.save(out_image, quality=90)

# Задаём обои
def set_background(path):
    if not os.path.exists(path):
        print(f'\n2-Файл не найден: {path}')
        exit()

    desktop_session = os.environ.get("XDG_CURRENT_DESKTOP")
    print(f'\ndesktop_session: {desktop_session}')

    # KDE
    if desktop_session.lower() == 'kde':
        command = f'plasma-apply-wallpaperimage {path}'
        print(f'\n{command}\n')
        os.system(command)

    # CINNAMON
    if desktop_session.lower() == 'cinnamon':
        commands = []
        commands.append(f'gsettings set org.cinnamon.desktop.background picture-uri file://{path}')
        commands.append('gsettings get org.cinnamon.desktop.background picture-uri')
        commands.append('gsettings set org.cinnamon.desktop.background picture-options zoom')
        commands.append('gsettings get org.cinnamon.desktop.background picture-options')
        for command in commands:
            print(f'\n{command}')
            os.system(command)

# Завершить сценарий, если данное изображение было скачано ранее
def check_exist(url):
    if os.path.exists(out_image):
        with Image.open(out_image) as im:
            comment = im.info['comment']
        print('\ncomment: ', comment)
        print('url: ', url)
        if url.encode('ASCII') == comment:
            set_background(out_image)
            print('Изображение было скачано ранее\ncomment и url совпадают')
            print('\nЗавершаем сценарий')
            exit()

# ----------------------------------------------

#set_background(default_image)

# Скачиваем html страницу
#url = 'https://apod.nasa.gov/apod/ap231230.html'
website = requests.get(url, timeout=5)

if not website:
    # Не удалось скачать htmlset_background
    print(website)
    exit()

soup = BeautifulSoup(website.content, 'html.parser')
#print(soup.prettify())
try:
    # Низкое качество
    img_src = soup.img['src']
except Exception:
    img_src = None
print('\nimg_src', img_src)

img_href = None
if img_src:
    # Изображение по ссылке (хорошее качество)
    for a in soup.find_all('a', href=True):
        if '.jpg' in a['href'] or '.png' in a['href']:
            img_href = a['href']
            break
    else:
        img_href = None
    print('\nimg_href', img_href)

    if img_href and best_quality:
        img_url = f'{base_url}/{img_href}'
    elif img_src:
        img_url = f'{base_url}/{img_src}'
    print('\nimage url:', img_url)
    image_ext = img_url[img_url.rfind('.')+1:]
    print('\nimage ext:', image_ext)

    check_exist(img_url)

    try:
        r = requests.get(img_url, timeout=5, stream=True)
        if r.status_code == 200:
            with open(f'{tmp_path}.{image_ext}', 'wb') as f:
                f.write(r.content)
    except Exception:
        print(f'Не удалось скачать изображение {img_url}')
    else:
        processing_image(f'{tmp_path}.{image_ext}', img_url)

if (not img_href) and (not img_src):
    print('\nИщем ссылку YouTube\n')
    iframe = soup.find('iframe')
    if iframe:
        check_exist(iframe['src'])
        print(iframe['src'])

        yt_opts = {
            'writethumbnail': True,
            'embedthumbnail': True,
            'skip_download': True,
            'outtmpl': tmp_path,
            'socket_timeout': 5
            }
        with yt_dlp.YoutubeDL(yt_opts) as ydl:
            ydl.download(iframe['src'])

    processing_image(f'{tmp_path}.webp', iframe['src'])


set_background(out_image)
