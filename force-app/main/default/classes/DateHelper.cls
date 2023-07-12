public with sharing class DateHelper {
    

    public static Date getNextSaturday(Date d) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        Integer daysUntilSaturday = 6 - Integer.valueOf(dt.format('u'));
        return d.addDays(daysUntilSaturday);
    }

    public static Date getNextSunday(Date d) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        Integer daysUntilSunday = 7 - Integer.valueOf(dt.format('u'));
        return d.addDays(daysUntilSunday);
    }

    public static Date getNextMonday(Date d) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        Integer daysUntilMonday = 8 - Integer.valueOf(dt.format('u'));
        if (daysUntilMonday == 7) {
            return d;
        }
        return d.addDays(daysUntilMonday);
    }

}