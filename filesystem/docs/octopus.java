import java.io.*;
import java.util.*;
import java.util.Vector;
import java.*;
import java.net.*;

public class octopus {
 public static void main(String[] args)
 {try{
 System.out.println("Octopus - A chumby widget downloader - (C) 2012 Zurk\n\n\n");
System.out.println("1] Creating download catalog .... ");
downloader(new URL("http://xml.chumby.com/xapis/catalog"),"catalog");
System.out.println("2] Creating stage 1/2/3/4 directory ... ");
new File("stage1").mkdir();
new File("stage2").mkdir();
new File("stage3").mkdir();
new File("stage4").mkdir();
System.out.println("3] Processing downloaded catalog .... ");
stage1urls("catalog");
System.out.println("4] Processing downloaded categories .... ");
String files[]=getfiles("stage2"); int i=0;
 for( String fn : files ) { i++; System.out.println(" "+ i + " >> Processing "+fn); stage2urls("stage2/"+fn); }

System.out.println("Complete! Look in the stage 1/2/3/4/5 directories for widget files.");
 }catch (Exception e){System.out.println(" Error : "+e.toString());}}


public static void stage2urls(String filename)throws Exception {
String s=readFile(filename);
System.out.println(" > 2Processing : "+filename);
 String [] parts = s.split("\"");
Vector v=new Vector();
        for( String item : parts ) {
            if(item.startsWith("http://")){v.addElement(item);}
            if(item.startsWith("/xapi")){v.addElement("http://xml.chumby.com"+item);}
            if(item.startsWith("/xml")){v.addElement("http://xml.chumby.com"+item);}
                                   }

Vector vx=new Vector(); boolean flag=false;
for(int i=0; i<v.size(); i++){ flag=false;
String c = (String) v.get(i);
for(int j=0; j<vx.size(); j++){ String x=(String)vx.get(j); if(x.compareTo(c)==0){flag=true;} }
if(flag){}else{vx.addElement(c);} }
String xitem;
for(int i=0;i<vx.size();i++){ xitem=(String)vx.get(i);
if(xitem.startsWith("http://xml.chumby.com")){
downloader(new URL(xitem),"stage3/"+xitem.substring(xitem.lastIndexOf('/')+1,xitem.length()) );}
else{downloader(new URL(xitem),"stage4/"+xitem.substring(xitem.lastIndexOf('/')+1,xitem.length()) );}
  }

}

public static void stage1urls(String filename)throws Exception {
String s=readFile(filename);
System.out.println(" > 1Processing : "+filename);
 String [] parts = s.split("\"");
        for( String item : parts ) {
            if(item.startsWith("http://")){downloader(new URL(item),"stage1/"+item.substring(item.lastIndexOf('/')+1,item.length()) );}
            if(item.startsWith("/xapi")){downloader(new URL("http://xml.chumby.com"+item),"stage2/"+item.substring(item.lastIndexOf('/')+1,item.length()) );}
}}

public static String[] getfiles(String dirx){
File dir = new File(dirx);
String[] children = dir.list();
if (children == null) {
    // Either dir does not exist or is not a directory
} else {
    for (int i=0; i<children.length; i++) {
        // Get filename of file or directory
        String filename = children[i];
    }
}
FilenameFilter filter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
        return !name.startsWith(".");
    }
};
children = dir.list(filter);
return children;}


public static String readFile(String fileName) throws Exception{
    File file = new File(fileName);
    char[] buffer = null;
        BufferedReader bufferedReader = new BufferedReader(new FileReader(file));
        buffer = new char[(int)file.length()];
        int i = 0;
        int c = bufferedReader.read();
        while (c != -1) {
            buffer[i++] = (char)c;
            c = bufferedReader.read();
        }
    return new String(buffer);  }

public static void downloader(URL ux,String filename) throws Exception{
Thread.sleep(250);URL u=new URL(ux.toString()+"?hw=10.7&sw=1.8.2");
if((u.toString()).contains("chumby.com")){
File f=new File(filename); while (f.exists()){filename=filename+"X";f=new File(filename);}
System.out.println("> Downloading "+u.toString()+" to "+filename);
URLConnection uc = u.openConnection();uc.connect();
InputStream in = uc.getInputStream();
FileOutputStream out = new FileOutputStream(filename);
final int BUF_SIZE = 1 << 8;
byte[] buffer = new byte[BUF_SIZE];
int bytesRead = -1;
while((bytesRead = in.read(buffer)) > -1) {
    out.write(buffer, 0, bytesRead);      }
in.close();out.flush();out.close();
}else{System.out.println("> Skipping : "+u.toString());}}

}
