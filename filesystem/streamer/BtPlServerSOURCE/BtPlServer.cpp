/*****************************************************************
|
|   BlueTune - Playlist Player Web Server
|   (c) 2011 Xavier Llamas Rolland
|
|   Based on work by:
|   (c) 2002-2008 Gilles Boccon-Gibod
|
 ****************************************************************/

/*----------------------------------------------------------------------
|    includes
+---------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>

#include "Atomix.h"
#include "Neptune.h"
#include "BlueTune.h"
#include "BtPlServer.h"

/*----------------------------------------------------------------------
|    logging
+---------------------------------------------------------------------*/
NPT_SET_LOCAL_LOGGER("bluetune.player.web")


/*----------------------------------------------------------------------
|    BtPlServer::BtPlServer
+---------------------------------------------------------------------*/
BtPlServer::BtPlServer(unsigned int port) : m_DecoderState(BLT_DecoderServer::STATE_STOPPED)
{
    // initialize status fields
    ATX_SetMemory(&m_StreamInfo, 0, sizeof(m_StreamInfo));
    ATX_Properties_Create(&m_CoreProperties);
    ATX_Properties_Create(&m_StreamProperties);
    
    // set ourselves as the player event listener
    m_Player.SetEventListener(this);
    
    // create the http server
    m_HttpServer = new NPT_HttpServer(port);
      
    // attach ourselves as a dynamic handler for commands
    m_HttpServer->AddRequestHandler(this, "/player", true);

    // attach ourselves as a dynamic handler for play list
    m_HttpServer->AddRequestHandler(this, "/pl", true);
}

/*----------------------------------------------------------------------
|    BtPlServer::~BtPlServer
+---------------------------------------------------------------------*/
BtPlServer::~BtPlServer()
{
    delete m_HttpServer;
    ATX_DESTROY_OBJECT(m_CoreProperties);
    ATX_DESTROY_OBJECT(m_StreamProperties);
}

/*----------------------------------------------------------------------
|    BtPlServer::Run
+---------------------------------------------------------------------*/
void
BtPlServer::Run()
{
    NPT_Result result;
    do {
        result = m_Player.PumpMessage();
    } while (NPT_SUCCEEDED(result));
}

/*----------------------------------------------------------------------
|    BtPlServer::Loop
+---------------------------------------------------------------------*/
NPT_Result
BtPlServer::Loop()
{
    // create a thread to handle notifications
    NPT_Thread notification_thread(*this);
    notification_thread.Start();

    NPT_Result result = m_HttpServer->Loop();

    // wait for the notification thread to end
    notification_thread.Wait();
    
    return result;
}

/*----------------------------------------------------------------------
|   BtPlServer::PlItem::PlItem
+---------------------------------------------------------------------*/
BtPlServer::PlItem::PlItem(const char* name, const char* url) 
{
    m_Name = name;
    m_Url = url;
}


/*----------------------------------------------------------------------
|    BtPlServer::DoSeekToTimecode
+---------------------------------------------------------------------*/
void
BtPlServer::DoSeekToTimecode(const char* time)
{
    BLT_UInt8    val[4] = {0,0,0,0};
    ATX_Size     length = ATX_StringLength(time);
    unsigned int val_c = 0;
    bool         has_dot = false;
    
    if (length != 11 && length != 8 && length != 5 && length != 2) return;
    
    do {
        if ( time[0] >= '0' && time[0] <= '9' && 
             time[1] >= '0' && time[0] <= '9' &&
            (time[2] == ':' || time[2] == '.' || time[2] == '\0')) {
            if (time[2] == '.') {
                if (length != 5) return; // dots only on the last part
                has_dot = true;
            } else {
                if (val_c == 3) return; // too many parts
            }
            val[val_c++] = (time[0]-'0')*10 + (time[1]-'0');
            length -= (time[2]=='\0')?2:3;
            time += 3;
        } else {
            return;
        }
    } while (length >= 2);
    
    BLT_UInt8 h,m,s,f;
    if (has_dot) --val_c;    
    h = val[(val_c+1)%4];
    m = val[(val_c+2)%4];
    s = val[(val_c+3)%4];
    f = val[(val_c  )%4];

    m_Player.SeekToTimeStamp(h,m,s,f);
}

/*----------------------------------------------------------------------
|    BtPlServer::SendStatus
+---------------------------------------------------------------------*/
NPT_Result
BtPlServer::SendStatus(NPT_HttpResponse& response, const char* jcallback)
{
    NPT_String json;
    
    json = NPT_String::Format("%s({\"status\": \"",jcallback);    
    // state
    switch (m_DecoderState) {
      case BLT_DecoderServer::STATE_STOPPED:
        json += "STOPPED";
        break;

      case BLT_DecoderServer::STATE_PLAYING:
        json += "PLAYING";
        break;

      case BLT_DecoderServer::STATE_PAUSED:
        json += "PAUSED";
        break;

      case BLT_DecoderServer::STATE_EOS:
        json += "EOS";
        break;

      default:
        json += "UNKNOWN";
        break;
    }
    json += "\",";
    
    // timecode
    json += NPT_String::Format("\"timecode\": \"%02d:%02d:%02d\",",
                               m_DecoderTimecode.h,
                               m_DecoderTimecode.m,
                               m_DecoderTimecode.s);
    
    // position
    json += NPT_String::Format("\"position\": \"%f\",", m_DecoderPosition);

    // stream info
    json += "\"streaminfo\": {";
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_NOMINAL_BITRATE) {
        json += NPT_String::Format("\"nominalBitrate\": \"%d\",", m_StreamInfo.nominal_bitrate);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_AVERAGE_BITRATE) {
        json += NPT_String::Format("\"averageBitrate\": \"%d\",", m_StreamInfo.average_bitrate);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_INSTANT_BITRATE) {
        json += NPT_String::Format("\"instantBitrate\": \"%d\",", m_StreamInfo.instant_bitrate);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_SIZE) {
        json += NPT_String::Format("\"size\": \"%d\",", m_StreamInfo.size);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_DURATION) {
        unsigned int seconds = m_StreamInfo.duration/1000;
        json += NPT_String::Format("\"duration\": \"%02d:%02d:%02d\",", 
                                   (seconds)/36000,
                                   (seconds%3600)/60,
                                   (seconds%60));
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_SAMPLE_RATE) {
        json += NPT_String::Format("\"sampleRate\": \"%d\",", m_StreamInfo.sample_rate);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_CHANNEL_COUNT) {
        json += NPT_String::Format("\"channelCount\": \"%d\",", m_StreamInfo.channel_count);
    }
    if (m_StreamInfo.mask & BLT_STREAM_INFO_MASK_DATA_TYPE) {
        json += NPT_String::Format("\"dataType\": \"%s\",", m_StreamInfo.data_type);
    }
    json += "},";
    
    // playlist pos
    
    json += NPT_String::Format("\"plpos\": \"%d\",",m_PlayListPosition);
    
    if (m_PlayList.GetItemCount() > 0){
        PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
        json += NPT_String::Format("\"track\": \"%s\"",item.m_Name.GetChars());
    }
    
    json += "})";
    
    // send the html document
    NPT_HttpEntity* entity = response.GetEntity();
    entity->SetContentType("application/json");
    entity->SetInputStream(json);        
    
    NPT_LOG_FINE_1("status: %s", json.GetChars());
    
    return NPT_SUCCESS;
}

/*----------------------------------------------------------------------
|    BtPlServer::SendPlayList
+---------------------------------------------------------------------*/
NPT_Result
BtPlServer::SendPlayList(NPT_HttpResponse& response, const char* jcallback)
{
    NPT_String json;
    
    json = NPT_String::Format("%s({\"items\": [",jcallback);    

    for (NPT_List<PlItem>::Iterator it = m_PlayList.GetFirstItem();
         it;
         ++it) {
         PlItem& item = *it;
         json += "{";
         json += NPT_String::Format("\"name\": \"%s\",",item.m_Name.GetChars());
         json += NPT_String::Format("\"url\": \"%s\"",item.m_Url.GetChars());
         json += "},";
    }


    json += "],";
    json += NPT_String::Format("\"plpos\": \"%d\"})",m_PlayListPosition);
    // send the html document
    NPT_HttpEntity* entity = response.GetEntity();
    entity->SetContentType("application/json");
    entity->SetInputStream(json);        
    
    NPT_LOG_FINE_1("status: %s", json.GetChars());
    
    return NPT_SUCCESS;
}

/*----------------------------------------------------------------------
|    BtPlServer::SetupResponse
+---------------------------------------------------------------------*/
NPT_Result 
BtPlServer::SetupResponse(NPT_HttpRequest&              request,
                              const NPT_HttpRequestContext& /*context*/,
                              NPT_HttpResponse&             response)
{
    const NPT_Url&    url  = request.GetUrl();
    const NPT_String& path = url.GetPath();
    NPT_UrlQuery      query;
    NPT_String        jcallback_field = "";
    
    // parse the query part, if any
    if (url.HasQuery()) {
        query.Parse(url.GetQuery());
        jcallback_field = query.GetField("jsoncallback");
    }
    
    // lock the player 
    NPT_AutoLock lock(m_Lock);
    
    
    // handle status requests
    if (path == "/player/status") {
        return SendStatus(response,jcallback_field);
    } else if (path == "/pl/get"){
        return SendPlayList(response,jcallback_field);
    } 
    
    // handle commands
    NPT_String msg = "OK";

    if (path == "/player/playdirect") {
        const char* url_field = query.GetField("url");
        if (url_field) {
            NPT_String url = NPT_UrlQuery::UrlDecode(url_field);
            m_Player.SetInput(url);
        } else {
            msg = "INVALID PARAMETERS";
        }
    } else if (path == "/player/play") {
        if (m_DecoderState == BLT_DecoderServer::STATE_PAUSED){
           m_Player.Play();
        }
        else if (m_PlayList.GetItemCount() > 0){
           PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
           m_Player.SetInput(item.m_Url.GetChars());
           m_Player.Play();
           msg = NPT_String::Format("OK %d",m_PlayListPosition);
        }
    } else if (path == "/player/playindex") {
        const char* index_field = query.GetField("index");
        NPT_Ordinal index = atoi(index_field);
        if (index_field && (m_PlayList.GetItemCount() > 0) && (index < m_PlayList.GetItemCount())){
                m_PlayListPosition = index;
                PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
                m_Player.SetInput(item.m_Url.GetChars());
                m_Player.Play();
                msg = NPT_String::Format("OK %d",m_PlayListPosition);
        }
        else {
           msg = "INVALID PARAMETERS";
        }
    } else if (path == "/player/next") {
        if (m_PlayList.GetItemCount() > 0){
           m_PlayListPosition++;
           if (m_PlayListPosition >= m_PlayList.GetItemCount())
              m_PlayListPosition = 0;
           PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
           m_Player.SetInput(item.m_Url.GetChars());
           m_Player.Play();
           msg = NPT_String::Format("OK %d",m_PlayListPosition);
        }
    } else if (path == "/player/prev") {
        if ((m_PlayList.GetItemCount() > 0) && (m_PlayListPosition > 0)){
           m_PlayListPosition--;
           PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
           m_Player.SetInput(item.m_Url.GetChars());
           m_Player.Play();
           msg = NPT_String::Format("OK %d",m_PlayListPosition);
        }
    } else if (path == "/player/top") {
        if (m_PlayList.GetItemCount() > 0){
           m_PlayListPosition = 0;
           PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
           m_Player.SetInput(item.m_Url.GetChars());
           m_Player.Play();
           msg = NPT_String::Format("OK %d",m_PlayListPosition);
        }
    } else if (path == "/player/pause") {
        m_Player.Pause();
    } else if (path == "/player/stop") {
        m_Player.Stop();
    } else if (path == "/player/seek") {
        const char* timecode_field = query.GetField("timecode");
        const char* position_field = query.GetField("position");
        if (timecode_field) {
            NPT_String timecode = NPT_UrlQuery::UrlDecode(timecode_field);
            DoSeekToTimecode(timecode);
        } else if (position_field) {
            unsigned int position;
            if (NPT_SUCCEEDED(NPT_ParseInteger(position_field, position))) {
                m_Player.SeekToPosition(position, 100);
            }
        } else {
            msg = "INVALID PARAMETER";
        }
    } else if (path == "/player/set-volume") {
        const char* volume_field = query.GetField("volume");
        if (volume_field) {
            unsigned int volume;
            if (NPT_SUCCEEDED(NPT_ParseInteger(volume_field, volume))) {
                m_Player.SetVolume((float)volume/100.0f);
            }
        } else {
            msg = "INVALID PARAMETER";
        }
    } else if (path == "/pl/add"){
        const char* name_field = query.GetField("name");
        const char* url_field = query.GetField("url");
        if (url_field && name_field){
            NPT_String url = NPT_UrlQuery::UrlDecode(url_field);
            NPT_String name = NPT_UrlQuery::UrlDecode(name_field);
            m_PlayList.Add(PlItem(name.GetChars(),url.GetChars()));
            return SendPlayList(response,jcallback_field);
        } else {
            msg = "INVALID PARAMETER";
        }
           
    } else if (path == "/pl/remove") {
        const char* index_field = query.GetField("index");
        NPT_Ordinal index = atoi(index_field);
        if (index_field && (m_PlayList.GetItemCount() > 0) && (index < m_PlayList.GetItemCount())){
            if (index < m_PlayListPosition){
               m_PlayListPosition--;
            }
            if (m_PlayListPosition >= m_PlayList.GetItemCount()){
               m_PlayListPosition = m_PlayList.GetItemCount() - 1;
            }
            m_PlayList.Erase(m_PlayList.GetItem(index));
            return SendPlayList(response,jcallback_field);
        }
        else {
           msg = "INVALID PARAMETERS";
        }
    } else if (path == "/pl/clear"){
      m_PlayList.Clear();
      m_PlayListPosition = 0;
    }
    
    NPT_HttpEntity* entity = response.GetEntity();
    entity->SetContentType("text/html");
    entity->SetInputStream(msg.GetChars());
    return NPT_SUCCESS;
}

/*----------------------------------------------------------------------
|    BtPlServer::OnDecoderStateNotification
+---------------------------------------------------------------------*/
void
BtPlServer::OnDecoderStateNotification(BLT_DecoderServer::State state)
{
    NPT_AutoLock lock(m_Lock);
    m_DecoderState = state;
    if ((m_DecoderState == BLT_DecoderServer::STATE_EOS) && (m_PlayListPosition < (m_PlayList.GetItemCount() - 1))){
       m_PlayListPosition++;
       PlItem& item = *m_PlayList.GetItem(m_PlayListPosition);
       m_Player.SetInput(item.m_Url.GetChars());
       m_Player.Play();
    }
}

/*----------------------------------------------------------------------
|    BtPlServer::OnStreamTimeCodeNotification
+---------------------------------------------------------------------*/
void 
BtPlServer::OnStreamTimeCodeNotification(BLT_TimeCode time_code)
{
    NPT_AutoLock lock(m_Lock);
    m_DecoderTimecode = time_code;
}

/*----------------------------------------------------------------------
|    BtPlServer::OnStreamPositionNotification
+---------------------------------------------------------------------*/
void 
BtPlServer::OnStreamPositionNotification(BLT_StreamPosition& position)
{
    NPT_AutoLock lock(m_Lock);
    if (position.range) {
        m_DecoderPosition = (float)position.offset/(float)position.range;
    } else {
        m_DecoderPosition = 0.0f;
    }
}

/*----------------------------------------------------------------------
|    BtPlServer::OnStreamInfoNotification
+---------------------------------------------------------------------*/
void 
BtPlServer::OnStreamInfoNotification(BLT_Mask update_mask, BLT_StreamInfo& info)
{       
    NPT_AutoLock lock(m_Lock);
    unsigned int mask = m_StreamInfo.mask|update_mask;
    ATX_DESTROY_CSTRING(m_StreamInfo.data_type);
    m_StreamInfo = info;
    m_StreamInfo.mask = mask;
    m_StreamInfo.data_type = NULL;
    ATX_SET_CSTRING(m_StreamInfo.data_type, info.data_type);
}

/*----------------------------------------------------------------------
|    BtPlServer::OnPropertyNotification
+---------------------------------------------------------------------*/
void 
BtPlServer::OnPropertyNotification(BLT_PropertyScope        scope,
                                       const char*              /* source */,
                                       const char*              name,
                                       const ATX_PropertyValue* value)
{
    ATX_Properties* properties = NULL;
    switch (scope) {
        case BLT_PROPERTY_SCOPE_CORE:   properties = m_CoreProperties;   break;
        case BLT_PROPERTY_SCOPE_STREAM: properties = m_StreamProperties; break;
        default: return;
    }
    
    // when the name is NULL or empty, it means that all the properties in that 
    // scope fo that source have been deleted 
    if (name == NULL || name[0] == '\0') {
        ATX_Properties_Clear(properties);
        return;
    }
    
    ATX_Properties_SetProperty(properties, name, value);
}
