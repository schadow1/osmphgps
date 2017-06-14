#! /bin/sh -x

############################################################################
#
# MODULE:       osmphgarmin map build script
#
# AUTHOR(S):    Ervin Malicdem schadow1@s1expeditions.com
#               Emmanuel Sambale esambale@yahoo.com emmanuel.sambale@gmail.com
#
# PURPOSE:      Shell script for creating Garmin maps from OSM data.
#               Requires mkgmap, gmapi-builder python script, nsis. 
#
#               This program is free software under the GNU General Public
#               License (>=v2).
#
#############################################################################

#Set these directory paths

download_dir=------
output_dir=------
split_dir=------
download_link=---
download_link_osmconvert=---
download_link_osmfilter=---


#Nothing to change below
#===========
cd ${download_dir}

# Download from geofabrik site
wget -c ${download_link}
ls -al

# Download OSMConvert
wget -O ${download_link_osmconvert}
ls -al

# Download OSMFilter
wget -O ${download_link_osmfilter}
ls -al

#Convert OSM file to boundary file
osmconvert philippines-latest.osm.pbf --out-o5m >philippines.o5m

#Extract boundaries data
osmfilter philippines.o5m --keep-nodes= --keep-ways-relations="boundary=administrative =postal_code postal_code=" --out-o5m > philippines-boundaries.o5m

#Export boundaries data
java -cp mkgmap.jar uk.me.parabola.mkgmap.reader.osm.boundary.BoundaryPreprocessor philippines-boundaries.o5m boundary

# Split the file using splitter.jar
java -jar splitter.jar --max-nodes=1000000 --keep-complete=true  philippines.osm.pbf --output-dir=${split_dir}

ls -al

# compile map with logging properties report
#time java -Dlog.config=logging.properties -Xmx2012m -jar mkgmap.jar --read-config=args.list ${output_dir} 
time java -Xmx2012m -jar mkgmap.jar --read-config=args.list --series-name="OSM Philippines $(date +%Y%m%d)" --description="OSM Philippines $(date +%Y%m%d)" --output-dir=${output_dir} ~/osm/routable_garmin/dev/split/*.osm.pbf


# gmapsupp.img generation
time java -Xmx2012m -jar mkgmap.jar --read-config=args2.list ~/osm/routable_garmin/dev/split/*.osm.pbf ~/osm/routable_garmin/dev/SCHADOW.TYP

ls -al

zip osmph_img_latest_dev.zip gmapsupp.img


# Gmapi for Mac Roadtrip installer
python gmapi-builder -t ${output_dir}/40000001.tdb -b ${output_dir}/40000001.img -s ${output_dir}/SCHADOW.TYP -i ${output_dir}/40000001.mdx -m ${output_dir}/40000001_mdr.img ${output_dir}/*.img

ls -al
zip -r osmph_macroadtrip_latest_dev.zip "OSM Philippines $(date +%Y%m%d).gmapi"
#mv osmph_macroadtrip_latest_dev.zip /home/maning/osm/routable_garmin/dev/
rm -rf "OSM Philippines $(date +%Y%m%d).gmapi"

cd ${output_dir}

ls -al

# Win Mapsource installer
makensis osmph_mapsource_installer_.nsi
mv osmph_winmapsource_latest_.exe /home/maning/osm/routable_garmin/dev/osmph_winmapsource_latest_dev.exe

#temporary mv
#mv osmph_winmapsource_latest_.exe /home/maning/Downloads/osm/routable_garmin/data/

rm *.img 
rm *.mdx 
rm *.tdb 

cd ..
rm *.img 
rm *.tdb
rm *.mdx

date > log.txt

#Miscellaneous

cd ${download_dir}

# upload to server
# archiving downloaded philippine osm file
mv philippines.osm.pbf archive/philippines_$(date +%Y%m%d).osm.pbf

