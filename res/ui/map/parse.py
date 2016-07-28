#-*- coding:utf-8 -*-
from xml.etree import ElementTree
import struct

#
def parseFun(text):
	rootNode = ElementTree.fromstring(text)
	#map
	#-------------------------------------
	mapAttr = rootNode.attrib
	dataMap = ('map = {w=%s, h=%s, tilew=%s, tileh=%s}' % 
		(mapAttr['width'], mapAttr['height'], mapAttr['tilewidth'], mapAttr['tileheight']))

	#tileset
	#-------------------------------------
	tileSets = rootNode.findall("tileset")
	firstFlag = True
	tileSet_ = {}
	tileImgs_ = []
	tiles_ = []
	for tileSet in tileSets:
		tileSetAttr = tileSet.attrib
		#---------
		if firstFlag:
			firstFlag = False
			tilePos = tileSet.find('tileoffset')
			tileSet_['x'] = 0
			tileSet_['y'] = 0
			if tilePos:
				tilePosAttr = tilePos.attrib
				tileSet_['x'] = int(tilePosAttr['x'])
				tileSet_['y'] = int(tilePosAttr['y'])
				
			tileSet_['w'] = int(tileSetAttr['tilewidth'])
			tileSet_['h'] = int(tileSetAttr['tileheight'])
		#---------
		img = tileSet.find('image')
		imgAttr = img.attrib
		tileImg_ = {}
		tileImg_['fgid'] = int(tileSetAttr['firstgid'])
		tileImg_['path'] = imgAttr['source']
		wNum = int(imgAttr['width'])/tileSet_['w']
		hNum = int(imgAttr['height'])/tileSet_['h']
		tileImg_['w'] = wNum
		tileImg_['h'] = hNum
		tileImgs_.append(tileImg_)
		for i in range(0, hNum):
			for i in range(0, wNum):
				tiles_.append(0)
		#---------
		tiles = tileSet.findall('tile')
		for tile in tiles:
			tilePros = tile.find('properties')
			if tilePros is not None:
				tilePrts = tilePros.findall('property')
				for tilePrt in tilePrts:
					tilePrtAttr = tilePrt.attrib
					if tilePrtAttr['name']=="attr":
						tileAttr = tile.attrib
						tiles_[tileImg_['fgid']+int(tileAttr['id'])-1] = int(tilePrtAttr['value'])
	#---
	dataTileSet = ('tileSet = {w=%d, h=%d, x=%d, y=%d}' % 
				(tileSet_['w'], tileSet_['h'], tileSet_['x'], tileSet_['y']))
	#---
	dataImgs = 'imgs = '
	dataImgs += '\n    {'
	for tileImg_ in tileImgs_:
		dataImgs += ('\n        {path="%s", firstid=%d, w=%d, h=%d},' % (tileImg_['path'], tileImg_['fgid'], tileImg_['w'], tileImg_['h']))
	dataImgs += '\n    }'
	
	#---
	dataTiles = 'tiles = {'
	for tile_ in tiles_:
		dataTiles += '%d,'%tile_
	dataTiles += '}'
	
	mapInfo = 'local kingdomMapInfo = '
	mapInfo += '\n{'
	mapInfo += '\n    '+dataMap+','
	mapInfo += '\n    '+dataTileSet+','
	mapInfo += '\n    '+dataImgs+','
	mapInfo += '\n    '+dataTiles
	mapInfo += '\n}'
	mapInfo += '\n\nreturn kingdomMapInfo'
	
	f = open('kingdomMapInfo.lua', 'w')
	f.write(mapInfo)
	f.close()
	
	
	#data
	data = rootNode.find('layer/data')
	dataStr = data.text.split(',')
	dataClient = [int(i) for i in dataStr]
	dataTmp = [tiles_[i-1] for i in dataClient]
	dataLen = len(dataTmp)
	mapW = int(mapAttr['width'])
	dataServer = range(dataLen*2)
	for i in range(dataLen):
		lineNum = i/mapW
		if lineNum%2==0:
			dataServer[i*2] = dataTmp[i]
			dataServer[i*2+1] = 0
		else:
			dataServer[i*2] = 0
			dataServer[i*2+1] = dataTmp[i]
	
	f = open('data.client', 'wb')
	bytes = struct.pack('%db' % len(dataClient), *dataClient)
	f.write(bytes)
	f.close()
	
	f = open('data.server', 'wb')
	bytes = struct.pack('%db' % len(dataServer), *dataServer)
	f.write(bytes)
	f.close()
	
if __name__ == '__main__':
	parseFun(open("map5.tmx").read())