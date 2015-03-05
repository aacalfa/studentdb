> import Network.Socket

In this example, we will actually do something useful using IO.
We live in the Internet age, so let's look at some socket programming.
Doing this in Idris is very similar to doing it in C, and Idris'
implementation is merely a wrapper for libc.

As in typical C socket programming, we usually have some sort of wrapper to 
repeatedly call recv until all data in a large stream has been read.
Here is that function in Idris.  Note the return type is "IO (String)", since
we do some IO operation (calling recv), which returns a string.  We stop
when a call to recv returns no data.

> recvAll : Socket -> IO (String)
> recvAll sock = do ret <- recv sock 4096
>                   case ret of
>                      Right (content,len) => case len of
>                                             0 => return ("")
>                                             _ => return (content ++ !(recvAll sock))
>                      Left _ => return ("")


Here is the stuff we want to connect to.  Command line argument parsing is 
kind of broken in Idris, so making this into a useful command-line program 
is left as an exercise to the reader.
Here, we fetch the front page of the UCSB CS website.

> hostname : String
> hostname = "cs.ucsb.edu"
> port : Int
> port = 80
> path : String
> path = "/"

Here's our main function.  We first open the socket, which returns an Either
value, meant to encode error values in a monadic way.  No matter what, this
call will always return Either an actual socket (called the "Right" of an
Either), or a SocketError, (as the Left of the Either).  We're ignoring the 
SocketError here.

Note that we have to pass the socket around.
But this is functional-programming-land with Effects and stuff! Can we avoid
that?
Idris doesn't have Network-related effects currently, but we have them for
file IO.  See studentdb.lidr for an example of this.

> main : IO ()
> main = do s <- socket AF_INET Stream 0
>           case s of
>             Right sock => do res <- connect sock (Hostname hostname) port
>                              send sock ("GET " ++ path ++ " HTTP/1.1\nHost: " ++ hostname ++ "\nAccept: */*\n\n")
>                              page <- recvAll sock
>                              putStrLn page
>             Left => putStrLn ("Error Opening Socket")
>           return ()
