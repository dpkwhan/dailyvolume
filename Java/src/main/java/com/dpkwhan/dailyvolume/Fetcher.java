package com.dpkwhan.dailyvolume;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Calendar;
import java.util.logging.*;

import org.apache.commons.io.FileUtils;
import picocli.CommandLine;
import picocli.CommandLine.Option;

class Fetcher {
    private static Logger LOGGER = null;

    static {
        System.setProperty("java.util.logging.SimpleFormatter.format", "%1$tF %1$tT %4$-7s %5$s %n");
        LOGGER = Logger.getLogger(Fetcher.class.getName());
    }
    @Option(names = { "-s", "--startDate" }, defaultValue = "", description = "Start date")
    private String startDate;

    @Option(names = { "-e", "--endDate" }, defaultValue = "", description = "End date")
    private String endDate;

    public void fetch() throws IOException {
        int startYear, endYear;
        if (startDate.isEmpty()) {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_MONTH, -6);
            startYear = cal.get(Calendar.YEAR);
        } else {
            startYear = Integer.parseInt(startDate.substring(0, 4));
        }

        if (endDate.isEmpty()) {
            Calendar cal = Calendar.getInstance();
            endYear = cal.get(Calendar.YEAR);
        } else {
            endYear = Integer.parseInt(endDate.substring(0, 4));
        }

        LOGGER.info("Parameters: startYear=" + startYear + ", endYear=" + endYear);
        for (int year = startYear; year <= endYear; year++) {
            this.downloadSingleFile(year);
        }
    }

    public void downloadSingleFile(final int year) throws IOException {
        final String BASE_URL = "http://markets.cboe.com/us/equities/market_statistics/historical_market_volume";
        final String filename = String.format("market_history_%d.csv", year);
        final String url = String.format("%s/%s-dl", BASE_URL, filename);
        final String outpath = System.getProperty("user.dir") + "/data";
        final String outfile = String.format("%s/%s", outpath, filename);
        FileUtils.copyURLToFile(new URL(url), new File(outfile));
        LOGGER.info("Saved to " + outfile);
    }

    public static void main(String[] args) throws IOException {
        final Fetcher fetcher = new Fetcher();
        new CommandLine(fetcher).parseArgs(args);
        fetcher.fetch();
    }
}
