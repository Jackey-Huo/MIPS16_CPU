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
    return ((img.astype("float32")) / 32).astype("uint8") 

def recon(img):
    img_rec = img8 * 32 + 16
    img_rec[img_rec > 255] = 255
    return img_rec.astype("uint8")

def serialize(f, img, start=0x001000):
    print("%x" % start)
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

#namea = "C:\\Users\\atlantix\\Desktop\\terminal.PNG"
#nameb = "C:\\Users\\atlantix\\Desktop\\terminal.bmp"
#nametxt = "C:\\Users\\atlantix\\Desktop\\flash_terminal.txt"

#namea = "C:\\Users\\atlantix\\Desktop\\img.png"
#nameb = "C:\\Users\\atlantix\\Desktop\\img.bmp"
#nametxt = "C:\\Users\\atlantix\\Desktop\\flash_win.txt"

sery = True


if sery == False:
    namea = "C:\\Users\\atlantix\\Desktop\\terminal.PNG"
    nameb = "C:\\Users\\atlantix\\Desktop\\terminal.bmp"
    flash_name = "C:\\Users\\atlantix\\Desktop\\flash_terminal.txt"
    f = open(flash_name, "w")
    out_shape = (400, 630)
    img = imread (namea)
    imgr = resize(img, out_shape)
    imgr = (imgr - imgr.min()) / (imgr.max() - imgr.min()) * 255
    img8 = quantize(imgr)
    imwrite(nameb, recon(img8))

elif sery == True:
    in_name_format = "C:\\Users\\atlantix\\Desktop\\410_v1.5\\幻灯片%d.PNG"
    out_name_format = "C:\\Users\\atlantix\\Desktop\\410_v1.5\\幻灯片%d.bmp"
    flash_name = "C:\\Users\\atlantix\\Desktop\\flash.txt"
    N = 18
    f = open(flash_name, "w")
    out_shape = (400, 630)


    for i in range(1, N+1, 1):
        namea = in_name_format % i
        nameb = out_name_format % i
        img = imread (namea)
        imgr = resize(img, out_shape)
        imgr = (imgr - imgr.min()) / (imgr.max() - imgr.min()) * 255
        img8 = quantize(imgr)
        imwrite(nameb, recon(img8))
        serialize(f, img8, start=(0x040000*i))
    f.close()