#!/bin/bash
#by raysuen
#version 2.0


#把下面的语句写入/etc/sudoers,保证在使用sudo是不提示密码
#raysuen ALL=(root) NOPASSWD:/sbin/mount
#raysuen ALL=(root) NOPASSWD:/sbin/umount
#raysuen ALL=(root) NOPASSWD:/sbin/mkdir


####################################################################################
#挂载单个分区到创建的目录，默认挂载目录为/Volumes
####################################################################################
Mount_NTFS(){
	sudo mkdir /Volumes/$2
	sudo mount -t ntfs -o rw,auto,nobrowse $1 /Volumes/$2
	ln -s /Volumes/$2 ~/Desktop/$2
	ln -s /Volumes/$2 ~/$2
}

####################################################################################
#卸载分区，根据传入的分区名称
####################################################################################
Umount_NTFS(){
	sudo umount /Volumes/$1
	[ -h ~/Desktop/$1 ]&& rm -f ~/Desktop/$1
	[ -h ~/$1 ]&& rm -f ~/$1
}


####################################################################################
#删除软件链接
####################################################################################
Delete_LN(){
	[ -h ~/Desktop/$1 ]&& rm -f ~/Desktop/$1
	[ -h ~/$1 ]&& rm -f ~/$1
}

####################################################################################
#挂载硬盘的函数，默认挂载所有没被挂载的NTFS分区
####################################################################################
Main_Mount(){
	Mounted_disk=(`mount | awk '/^\/dev/{print $1}'`)
	MountedNum=0
	##循环外接硬盘
	for j in `diskutil list | awk '/^\/dev/&&/external/{print $1}'`
	do

		#获取硬盘的分区路径
		DiskPaths=`diskutil list $j | awk '/Windows_NTFS/{print "/dev/"$NF}'`
		#获取硬盘的别名
		DiskNames=`diskutil list $j | awk '/Windows_NTFS/{for(i=3;i<NF-2;i++){if(i>3) {printf " "$i} else {printf $i}}}END{printf "\n"}'`
		
		#循环挂载每个外接硬盘的分区
		ismount=no   #判断是否已挂载，默认为没有挂载  
		for n in "${!DiskPaths[@]}"
		do
			#循环已经挂载的硬盘，判断是否分区已经挂载
			for var in ${Mounted_disk[@]}
			do
				#已挂载的分区是否等于需要挂载的分区
				if [ "${var}" == "${DiskPaths[n]}" ];then
					ismount=yes
					break
				else 
					ismount=no
					continue	
				fi
			done
			
			#判断挂载点是否已挂载
			if [ "${ismount}" == "no" ];then
				#挂载NTFS类型的硬盘
				Mount_NTFS ${DiskPaths[n]} ${DiskNames[n]}
				let MountedNum++
				#echo "not mount"
			# else
# 				echo ${DiskNames[n]}" is mounted."
			fi
			
		done
		
	done
	if [ ${MountedNum} -eq 0 ];then
		echo "No new disk are mounted!"
	fi
}

####################################################################################
#显示已挂载的外接硬盘
####################################################################################
List_NTFS(){
	Mounted_disk=(`mount | awk '/^\/dev/{print $1}'`)
	##循环外接硬盘
	for j in `diskutil list | awk '/^\/dev/&&/external/{print $1}'`
	do

		#获取硬盘的分区路径
		DiskPaths=`diskutil list $j | awk '/Windows_NTFS/{print "/dev/"$NF}'`
		#获取硬盘的别名
		DiskNames=`diskutil list $j | awk '/Windows_NTFS/{for(i=3;i<NF-2;i++){if(i>3) {printf " "$i} else {printf $i}}}END{printf "\n"}'`
		
		#循环挂载每个外接硬盘的分区
		for n in "${!DiskPaths[@]}"
		do
			#循环已经挂载的硬盘，判断是否分区已经挂载
			for var in ${Mounted_disk[@]}
			do
				#已挂载的分区是否等于需要挂载的分区
				if [ "${var}" == "${DiskPaths[n]}" ];then
					echo ${DiskNames[n]}" is mounted."
					break	
				fi
			done
			
		done
		
	done
	
}

####################################################################################
#卸载所有已挂载的NTFS分区
####################################################################################
Umount_All(){
	Mounted_disk=(`mount | awk '/^\/dev/{print $1}'`)
	##循环外接硬盘
	for j in `diskutil list | awk '/^\/dev/&&/external/{print $1}'`
	do

		#获取硬盘的分区路径
		DiskPaths=`diskutil list $j | awk '/Windows_NTFS/{print "/dev/"$NF}'`
		#获取硬盘的别名
		DiskNames=`diskutil list $j | awk '/Windows_NTFS/{for(i=3;i<NF-2;i++){if(i>3) {printf " "$i} else {printf $i}}}END{printf "\n"}'`
		
		#循环挂载每个外接硬盘的分区
		for n in "${!DiskPaths[@]}"
		do
			#循环已经挂载的硬盘，判断是否分区已经挂载
			for var in ${Mounted_disk[@]}
			do
				#已挂载的分区是否等于需要挂载的分区,如果已挂载则umount
				if [ "${var}" == "${DiskPaths[n]}" ];then
					Umount_NTFS ${DiskNames[n]}
					break	
				fi
			done
			
		done
		
	done
}

####################################################################################
#删除失效的软链接
####################################################################################
Delete_Expired(){
	Mounted_disk=(`mount | awk '/^\/dev/{print $1}'`)
	HardNames=`diskutil list | awk '/^\/dev/&&/external/{print $1}'`
	if [ ${#DiskPaths[@]} -gt 0 ];then
		##循环外接硬盘
		for j in ${HardNames[@]}
		do
	
			#获取硬盘的分区路径
			DiskPaths=`diskutil list $j | awk '/Windows_NTFS/{print "/dev/"$NF}'`
			#获取硬盘的别名
			DiskNames=`diskutil list $j | awk '/Windows_NTFS/{for(i=3;i<NF-2;i++){if(i>3) {printf " "$i} else {printf $i}}}END{printf "\n"}'`
			
			
				#循环挂载每个外接硬盘的分区
				for n in "${!DiskPaths[@]}"
				do
					#循环已经挂载的硬盘，判断是否分区已经挂载
					for var in ${Mounted_disk[@]}
					do
						#已挂载的分区是否等于需要挂载的分区,如果已挂载则umount
						if [ "${var}" == "${DiskPaths[n]}" ];then
							break
						else
							Delete_LN ${DiskNames[n]}
						fi
					done
					
				done
		done
	else
		for t in `ls ~/`
		do
			Delete_LN $t
		done
		for t in `ls ~/Desktop`
		do
			Delete_LN $t
		done
	fi
		
		
}

####################################################################################
#帮助函数
####################################################################################
help_fun(){
    echo "Discription:"
    echo "        This is a script to mount/umount external disks."
    echo "Parameters:"
    echo "        -m    specify a value for mount action."
    echo "            	the value is a disk alia,default all."
    echo "        -u    specify a value for umount action."
    echo "            	the value is a disk alia,default all."
    echo "        -l    list mounted disks."
    echo "        -d    delete expired link."
    echo "        -h    to get help."
}


##################################################################
#脚本的执行入口，获取参数
##################################################################
#如果没有参数输入，默认执行挂载外部磁盘
if [ $# -eq 0 ];then
	Main_Mount
	exit 0
fi
while (($#>=1))
do
    case `echo $1 | sed s/-//g | tr [a-z] [A-Z]` in
        H)
            help_fun          #执行帮助函数
            exit 0
        ;;
        U)
            shift
            if [ $# -eq 0 ];then
            	Umount_All
            	exit 0
            elif [ $# -eq 1 ];then
            	Umount_NTFS $1
            	exit 0
            else
            	echo "You must specify a right parameter."
            	echo "You can use -h or -H to get help."
            	exit 99
            fi
        ;;
        L)
        	shift
        	if [ $# -eq 0 ];then
        		List_NTFS
        	else
        		echo "You must specify a right parameter."
            	echo "You can use -h or -H to get help."
            	exit 98
        	fi
        ;;
        D)
        	shift
        	if [ $# -eq 0 ];then
        		Delete_Expired
        	else
        		echo "You must specify a right parameter."
            	echo "You can use -h or -H to get help."
            	exit 97
        	fi
        ;;
        M)
        	shift
        	if [ $# -eq 0 ];then
        		Main_Mount
        	else
        		echo "You must specify a right parameter."
            	echo "You can use -h or -H to get help."
            	exit 96
        	fi
        ;;
        *)
            echo "You must specify a right parameter."
            echo "You can use -h or -H to get help."
            exit 95
        ;;
    esac
done
