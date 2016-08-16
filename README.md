# VagrantCI


### Overview
a Poor Man's CI System using Vagrant and VirtualBox


### Features
- CI System (almost compatible with circle CI command syntax)
- Free and open source (GPL v2 licensed)
- supports only repositories hosted on github (for now)

### System Requirements
- VirtualBox    [https://www.virtualbox.org/]
- Vagrant       [https://www.vagrantup.com/]
- git           [https://en.wikipedia.org/wiki/Git_%28software%29]
- circle.yml inside the source repository (for build commands)
- minimum 10GByte free diskspace
- minimum 8GByte RAM

### Installation (on Ubuntu)
- install requirements:
<pre>apt-get install virtualbox vagrant git</pre>
- create a dummy user that only has access to it's own homedir
- change to that dummy user
- clone repository you want to run in your CI machine:
<pre>git clone https://github.com/zoff99/Etar-Calendar.git
cd Etar-Calendar</pre>
- checkout the commit you want to run:
<pre>git checkout 32f1508713f95b1b6188f32bfcc7f0388170ace4</pre>
- now add VagrantCI to the mix:
<pre>git clone https://github.com/zoff99/_vagrantci_.git</pre>
- this will add a "\_vagrantci\_" directory
- enter directory:
<pre>cd \_vagrantci\_</pre>
- installation is now complete

### Running (the first time) [starting from $HOME]
- the first ever run will take a long time, depending on your internet connection and your system (it may take up to 1 hour):
<pre>cd Etar-Calendar
cd \_vagrantci\_
bash ./vagrantci.sh run</pre>

### Running (continuously) [starting from $HOME]
- checkout your code and run it in CI:
<pre>cd Etar-Calendar
git pull
git checkout &lt;new commit hash&gt;
cd \_vagrantci\_
bash ./vagrantci.sh run
</pre>
- that's it

### Contributions welcome!
Please report bugs and include logs.


