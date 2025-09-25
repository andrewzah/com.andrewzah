---
title: "How to run Kakaotalk on Linux (2020)"
aliases:
  - "/posts/2020/how-to-kakaotalk-linux-2021"
  - "/posts/2020/how-to-kakaotalk-linux-2020"
  - "/posts/2020/how-to-kakaotalk-linux"
date: "2020-10-05"
tags: ["linux", "south korea"]
keywords: "kakaotalk linux kkt 카카우톡 카톡 how to instruction tutorial"
description: "How to set up Kakaotalk on Linux"
---

Thankfully, installing Kakaotalk has become much easier than before now that
it’s 64bit.

> [!WARNING]
> As of 2021-07-08, unfortunately, there is a bug where if you have more than
> 2-3 lines of input in the chat window, Kakaotalk crashes. I have no idea how
> to fix this, and it’s pretty annoying.

## Preparation

For this, we’ll need to install wine and playonlinux. This guide assumes you’re
using debian/ubuntu, but it should work the same for other distros.

```shell
$ sudo apt install -y wine playonlinux
```

Next, download the PC version of
[Kakaotalk.exe](https://www.kakaocorp.com/service/KakaoTalk?lang=en).

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/kakaotalk_exe.png" alt="Kakaotalk download page" />
</figure>

## Install

Open `playonlinux` and click Install. (Kakaotalk will show up here once you’ve
installed it).

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/playonlinux_main.png" alt="Main menu of playonlinux" />
</figure>

Click `Install a non-listed program`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/playonlinux_install_nonlisted.png" alt="Install a non-listed program window" />
</figure>

Click through the initial prompts. Then select
`Install a program in a new virtual drive`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/install_new_virtual_drive.png" alt="Install a program in a new virtual drive window" />
</figure>

Give it a name with no spaces, such as `kakaotalk` or `kkt`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/drive_name.png" alt="Enter a drive name window" />
</figure>

Don’t check any of these options, just click `Next`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/pre_install_choices.png" alt="Pre-install choices window" />
</figure>

Select `64 bits windows installation` and wait a bit for the drive to be
created.

> [!IMPORTANT]
> Don't forget to do this step!

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/64_bits.png" alt="32bit or 64bit selection window" />
</figure>

Select the `Kakaotalk.exe` file you downloaded earlier.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/file_select.png" alt="File selection window" />
</figure>

Continue through the Kakaotalk installation, just hit `Next` until the last
prompt. Do not hit `Finish` before unselecting `Run KakaoTalk`.

Make sure to unselect `Run KakoTalk` before proceeding.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/installation_completed.png" alt="Kakaotalk installation completed" />
</figure>

Wait for playonlinux to scan the drive, then select `Kakaotalk.exe` for the
shortcut. Give it whatever shortcut name you want, like `KakaoTalk`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/select_shortcut.png" alt="Shortcut selection window" />
</figure>

Now select `I don't want to make another shortcut`.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/2nd_shortcut_select.png" alt="Shortcut selection window again" />
</figure>

Kakaotalk is now installed! You should now see this screen:

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/2020_10_05_kakaotalk_linux/main_menu.png" alt="Playonlinux main menu" />
</figure>

Double click KakaoTalk and sign in. Congrats, you now have KakaoTalk running on
linux!
