/ Usage: q fetch.q -startDate 2007.01.01 -endDate 2010.05.12

fetch:{[year]
    baseUrl:"http://markets.cboe.com/us/equities/market_statistics/historical_market_volume/";
    filename:"market_history_",string[year],".csv";
    url:baseUrl,filename,"-dl";
    res:.Q.hg hsym `$url;
    currentPath:system "cd";
    hsym[`$currentPath,"/data/",filename] 0: enlist res
  };

params:.Q.def[`startDate`endDate!(.z.D-6;.z.D)].Q.opt .z.x;
startYear:`year$params`startDate;
endYear:`year$params`endDate;
show string[.z.P]," startDate=",string[params`startDate]," endDate=",string[params`endDate];
years:startYear+til 1+endYear-startYear;

fetch each years

\\

