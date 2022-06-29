# dna

This project was started to make genetic genealogy easier.  In particular, 
I needed a free and easy way to store information on not only my
own DNA matches but also on my family members'.  Furthermore, I needed
a way to do this for MyHeritage *and* 23andMe kits.

This project contains the code necessary to create a database in
PostgreSQL to store information on MyHeritage and 23andMe kits
that you manage.  It will allow you to store hypothesized 
common ancestors on both a general and a by-segment basis.  
Ancestors will be stored using FamilySearch IDs so that they can be 
uniquely identified.  

The best part of this database is a feature that allows you to view your
segment data in order.  That is, it effectively overlays segment
data from both MyHeritage and 23andMe, allowing you to make common 
ancestor judgment calls that much more easily.  It's effectively
an Advanced DNA Comparison Tool or Chromosome Browser that works
across both MyHeritage and 23andMe datasets.

Enjoy!