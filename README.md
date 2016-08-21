# VagrantCI

a Poor Man's CI System using Vagrant and VirtualBox

### Overview
VagrantCI is a [Continuous integration System](https://en.wikipedia.org/wiki/Continuous_integration) that runs locally on your machine. Virtualization is achieved with [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).


### Features
- CI System (almost compatible with circle CI command syntax)
- Free and open source (GPL v2 licensed)
- supports only repositories hosted on github (for now)

### System Requirements
| Component   |            |     |
| ----------- | ----------:| ---:|
| VirtualBox  | [https://www.virtualbox.org/] ||
| Vagrant     | [https://www.vagrantup.com/] ||
| git         | [https://en.wikipedia.org/wiki/Git_%28software%29] ||
| circle.yml  | inside the source repository (for build commands) ||
| Diskspace   | minimum 20GByte free ||
| RAM         | minimum 8GByte ||

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
- ("Etar-Calendar" is just an example!)

### Directory Tree
your directory tree should look something like this:
<pre>
.
|-- .git
|-- circle.yml
|-- _vagrantci_
|   |-- dl
|   |-- tools
|   |-- Vagrantfile
|   |-- vagrantci.bat
|   |-- vagrantci.sh
</pre>

### Running (the first time) [starting from $HOME]
- the first ever run will take a long time, depending on your internet connection and your system (it may take up to 15 minutes):
<pre>cd Etar-Calendar
cd \_vagrantci\_
bash ./vagrantci.sh run</pre>
- ("Etar-Calendar" is just an example!)

### Running (continuously) [starting from $HOME]
- checkout your code and run it in CI:
<pre>cd Etar-Calendar
git pull
git checkout &lt;new commit hash&gt;
cd \_vagrantci\_
bash ./vagrantci.sh run
</pre>
- that's it
- - ("Etar-Calendar" is just an example!)

### Results of CI runs [starting from $HOME]
all files and logs of every CI run will be saved to the **\_vagrantci\_/www/** directory
you can also access the results with any webbroswer on your host machine at **http://localhost:56999/**

### ssh into the CI box [starting from $HOME]
<pre>cd Etar-Calendar
cd _vagrantci_
vagrant ssh
</pre>
if you have multiple CI boxes running, you need to specify the box name to enter the desired box
- ("Etar-Calendar" is just an example!)

### Wiping VM and starting fresh [starting from $HOME]
this will take about 10 minutes loger than a normal CI run
<pre>cd Etar-Calendar
cd _vagrantci_
bash ./vagrantci.sh destroy
bash ./vagrantci.sh run</pre>
- ("Etar-Calendar" is just an example!)

### Contributions welcome!
Please report bugs and include logs.


