/*****************************************************************
|
|   BlueTune - Player Web Service
|
|   (c) 2002-2008 Gilles Boccon-Gibod
|   Author: Gilles Boccon-Gibod (bok@bok.net)
|
 ****************************************************************/

/*----------------------------------------------------------------------
|    includes
+---------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>

#include "BtPlServer.h"

/*----------------------------------------------------------------------
|    main
+---------------------------------------------------------------------*/
int
main(int argc, char** argv)
{
    if (argc < 2) {
        fprintf(stderr, "usage: BtPlServer <port> \n");
        return 1;
    }

    
    // parse the port
    int port = 0;
    if (NPT_FAILED(NPT_ParseInteger(argv[1], port, true))) {
        fprintf(stderr, "ERROR: invalid port\n");
        return 1;
    }
    
    // create the server
    BtPlServer* server = new BtPlServer(port);

    // loop until a termination request arrives
    server->Loop();
    
    // delete the controller
    delete server;

    return 0;
}
