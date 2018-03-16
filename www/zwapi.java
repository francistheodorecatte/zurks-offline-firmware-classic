import java.io.*;
import java.lang.*;

class zwapi {
    public static void main(String[] args) {
try {if (args.length > 0) {
String weather=args[0];
String destination=args[1];
File weatherf=new File(weather);
if(!weatherf.exists()){System.err.println("No weather!");System.exit(0);}
String weatherhtml=new String();
DataInputStream in = new DataInputStream(new FileInputStream(weather));
BufferedReader br = new BufferedReader(new InputStreamReader(in));
  String strLine;
  while ((strLine = br.readLine()) != null)   {  weatherhtml=weatherhtml+(strLine);  }
  in.close();

    StringBuffer returnMessage = new StringBuffer(weatherhtml);
    int startPosition = weatherhtml.indexOf("<"); // encountered the first closing braces
    int endPosition = weatherhtml.indexOf(">"); // encountered the first closing braces
    while( startPosition != -1 ) {
      returnMessage.delete( startPosition, endPosition+1 ); // remove the tag
      startPosition = (returnMessage.toString()).indexOf("<"); // look for the next closing brace
      endPosition = (returnMessage.toString()).indexOf(">"); // look for the next closing brace
    }

String tokens[];
String sparky;
weatherhtml=(returnMessage.toString());

tokens = weatherhtml.split("Conditions");
sparky=tokens[1];
tokens = sparky.split("Visibility");
sparky=tokens[0];

weatherhtml=(weatherhtml).replaceAll(" ", "");
weatherhtml=(weatherhtml).replaceAll("&deg;", "");

tokens = weatherhtml.split("Temperature");
weatherhtml=tokens[1];

tokens = weatherhtml.split("F");
String f=tokens[0];

tokens = weatherhtml.split("Conditions");
weatherhtml=tokens[1];

tokens = weatherhtml.split("Visibility");
weatherhtml=tokens[0];

int code=0;

/*
18,19,22,31 - sunny -
1 - sun w slight clouds -
3 - light snow -
4 - light rain w sun -
8 - snow w clouds 
9 - drizzle
12 - overcast 
13 - heavy clouds 
16 - heavy snow 
17 -  sun and wind 
20 - fog 
21 - mostly cloudy 
23 -  light clouds
25 - partly cloudy 
26 - smoke 
36 - light cloud rain with haze 
42 - thunderstorm 
*/
if(weatherhtml.contains("SnowShowers")){code=3;
}else if(weatherhtml.contains("IcePelletShowers")){code=16;
}else if(weatherhtml.contains("HailShowers")){code=16;
}else if(weatherhtml.contains("SmallHailShowers")){code=16;
}else if(weatherhtml.contains("Thunderstorm")){code=42;
}else if(weatherhtml.contains("ThunderstormsandRain")){code=42;
}else if(weatherhtml.contains("ThunderstormsandSnow")){code=42;
}else if(weatherhtml.contains("ThunderstormsandIcePellets")){code=42;
}else if(weatherhtml.contains("ThunderstormswithHail")){code=42;
}else if(weatherhtml.contains("ThunderstormswithSmallHail")){code=42;
}else if(weatherhtml.contains("FreezingDrizzle")){code=9;
}else if(weatherhtml.contains("FreezingRain")){code=36;
}else if(weatherhtml.contains("FreezingFog")){code=12;
}else if(weatherhtml.contains("Overcast")){code=13;
}else if(weatherhtml.contains("Clear")){code=18;
}else if(weatherhtml.contains("PartlyCloudy")){code=1;
}else if(weatherhtml.contains("MostlyCloudy")){code=25;
}else if(weatherhtml.contains("ScatteredClouds")){code=17;
}else if(weatherhtml.contains("SnowGrains")){code=8;
}else if(weatherhtml.contains("IceCrystals")){code=8;
}else if(weatherhtml.contains("IcePellets")){code=8;
}else if(weatherhtml.contains("VolcanicAsh")){code=26;
}else if(weatherhtml.contains("WidespreadDust")){code=26;
}else if(weatherhtml.contains("DustWhirls")){code=26;
}else if(weatherhtml.contains("Sandstorm")){code=26;
}else if(weatherhtml.contains("LowDriftingSnow")){code=8;
}else if(weatherhtml.contains("LowDriftingWidespreadDust")){code=8;
}else if(weatherhtml.contains("LowDriftingSand")){code=26;
}else if(weatherhtml.contains("BlowingSnow")){code=16;
}else if(weatherhtml.contains("BlowingWidespreadDust")){code=8;
}else if(weatherhtml.contains("BlowingSand")){code=26;
}else if(weatherhtml.contains("RainMist")){code=9;
}else if(weatherhtml.contains("RainShowers")){code=4;
}else if(weatherhtml.contains("Rain")){code=4;
}else if(weatherhtml.contains("Snow")){code=16;
}else if(weatherhtml.contains("Sand")){code=20;
}else if(weatherhtml.contains("Haze")){code=21;
}else if(weatherhtml.contains("Spray")){code=21;
}else if(weatherhtml.contains("Hail")){code=36;
}else if(weatherhtml.contains("Mist")){code=21;
}else if(weatherhtml.contains("Fog")){code=20;
}else if(weatherhtml.contains("Smoke")){code=26; 
}else if(weatherhtml.contains("Drizzle")){code=9;
}else{code=31;}

BufferedWriter out = new BufferedWriter(new FileWriter(destination,false));
out.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?><weatheritems><weatheritem timestamp=\"2011-12-14T08:27:22-08:00\"><location><city name=\"Zurkville\"/><state short=\"ZA\" long=\"Zurkville\"/><country short=\"ZZ\" long=\"Zurkian Empire\" medium=\"Zurkian Empire\"/><postalcode value=\"ZZ\"/></location><current><station_id>ZZ</station_id><observation_Time>2011-12-14T07:55:00-08:00</observation_Time><temp_f>"+f+"</temp_f><temp_c>"+f+"</temp_c><humidity></humidity><wind_direction>North</wind_direction><wind_mph>0.0</wind_mph><barometer>30.12</barometer><dewpoint_f></dewpoint_f><dewpoint_c></dewpoint_c><visibility>10.00</visibility><condition_code>"+code+"</condition_code><condition>"+sparky+"</condition></current></weatheritem></weatheritems>");
out.close();

} else {System.out.println ("Zurkian Chumby Hack - zwapi [path of weather] [path of final]");}
}catch (Exception e) {  System.err.println(e.toString());    }
}}


