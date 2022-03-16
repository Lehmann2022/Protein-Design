extract fls2, chain A
extract bak1, chain B
extract pep, chain C
remove inorganic

viewport 500, 500
bg_color white
color green, fls2
color smudge, bak1
color cyan, pep


#FLS2andBAK1
select C5_BF, br. ((fls2 within 5.0 of bak1) or (bak1 within 5.0 of fls2))
select C4_BF, ((fls2 within 4 of bak1) or (bak1 within 4 of fls2))
select C3_BF, ((fls2 within 3 of bak1) or (bak1 within 3 of fls2))

#Proteins vs. pep
select C5, br. ((fls2 within 5.0 of pep) or (pep within 5.0 of fls2) or (bak1 within 5.0 of pep) or (pep within 5.0 of bak1))
select C4, ((fls2 within 4.0 of pep) or (pep within 4.0 of fls2) or (bak1 within 4.0 of pep) or (pep within 3.0 of bak1))
select C3, ((fls2 within 3 of pep) or (pep within 3 of fls2) or (bak1 within 3 of pep) or (pep within 3 of bak1))

hide all
show surface
util.ray_shadows('occlusion1')
select none
set transparency, 0.5
show cartoon

#color distances
#color grey, flg
color yellow, C5
#color grey, C5_BF
show surface, C5
#show surface, C5_BF
color orange, C4
show surface, C4
#color orange, C4_BF
#show surface, C4_BF
color red, C3
#color red, C3_BF
show sticks, C5
#show sticks, C5_BF



#color grey for polarities
#color grey60, C1
#color grey60, C2
#color grey60, C3


#Show side by side
#rotate y, 80, fls2
#translate [-25,0,0], fls2
#rotate y, -100, lig
#translate [25,0,0], lig

#Show as initial again
#translate [25,0,0], fls2
#rotate y, -80, fls2
#translate [-25,0,0], lig
#rotate y, 100, lig


#3 way flip
#translate [35,0,0], fls2
#rotate y, -45, bak1
#translate [-25,0,0], bak1

