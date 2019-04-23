import java.util.*;
import java.text.*;

public class worldclock {
public static void main(String[] args) {
String timezone=args[0].split("TimeZone=")[1];
SimpleDateFormat fmt = new SimpleDateFormat("yyyy MM dd HH mm ss");
fmt.setTimeZone(TimeZone.getTimeZone(timezone));
String split[]=(fmt.format(new java.util.Date())).split(" ");
System.out.print("Year="+split[0]+"&Month="+split[1]+"&Day="+split[2]+"&Hour="+split[3]+"&Minute="+split[4]+"&Second="+split[5]+"&Millisecond=0");
  }
}
