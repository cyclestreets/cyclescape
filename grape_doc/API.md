### API



#### GET /api/issues(.json)

 Returns issues as a GoeJSON collection

**Parameters:** 


 - bbox (String) : Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793" 

 - tags (Array) : An array of tags all the issues must have, e.g. ["taga","tagb"] 

 - end\_date (Date) : No issues after the end date are returned 

 - start\_date (Date) : No issues before the start date are returned 

 - per\_page (Integer) : The number of issues per page, maximum of 500 

 - page (Integer) : The page number 




