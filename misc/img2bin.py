from imageio import imread, imwrite
from skimage.transform import resize
import numpy as np

def quantize(img):
    """
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            for k in range(img.shape[2]):
                x[i, j, k] = int(img[i, j, k] / 64)
    """
    return (img.astype("float32") / 64).astype("uint8") 

def recon(img):
    img_rec = img8 * 64
    img_rec[img_rec > 255] = 255
    return img_rec

def serialize(img, name, start=0x050000):
    f = open(name, 'w')
    cnt = 0
    print(img.shape)
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            r, g, b = img[i, j, :3]
            color = "{0:03b}{1:03b}{2:03b}".format(r, g, b)
            # print(color)
            # print(r, g, b)
            hex_color = ("%04x" % int(color, 2))
            hex_pos = ("%06x" % (cnt+start))
            f.write("%s=%s\n" % (hex_pos, hex_color))
            cnt = cnt + 1
    f.close()

#namea = "C:\\Users\\atlantix\\Desktop\\terminal.PNG"
#nameb = "C:\\Users\\atlantix\\Desktop\\terminal.bmp"
#nametxt = "C:\\Users\\atlantix\\Desktop\\flash_terminal.txt"

#namea = "C:\\Users\\atlantix\\Desktop\\img.png"
#nameb = "C:\\Users\\atlantix\\Desktop\\img.bmp"
#nametxt = "C:\\Users\\atlantix\\Desktop\\flash_win.txt"

namea = "C:\\Users\\atlantix\\Desktop\\模板-cpu战术\\幻灯片13.PNG"
nameb = "C:\\Users\\atlantix\\Desktop\\模板-cpu战术\\幻灯片13.bmp"
nametxt = "C:\\Users\\atlantix\\Desktop\\flash.txt"

img = imread (namea)
imgr = resize(img, (400, 630))
imgr = (imgr - imgr.min()) * (imgr.max() - imgr.min()) * 255
print(imgr.max(), imgr.min())
img8 = quantize(imgr)
print(img8.max(), img8.min())
imwrite(nameb, recon(img8))
serialize(img8, nametxt, start=0x090000)