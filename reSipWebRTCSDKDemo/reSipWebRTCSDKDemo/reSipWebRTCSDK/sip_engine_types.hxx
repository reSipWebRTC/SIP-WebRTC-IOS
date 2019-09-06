#ifndef SIP_ENGINE_API_TYPES_HXX
#define SIP_ENGINE_API_TYPES_HXX

#ifdef ENGINE_API_EXPORTS
#define ENGINE_API __declspec(dllexport)
#elif ENGINE_API_DLL
#define ENGINE_API __declspec(dllimport)
#elif defined(ANDROID) || defined(__APPLE__) || defined(__linux__)
#define ENGINE_API __attribute__ ((visibility("default")))
#else
#define ENGINE_API extern
#endif


#include <string>
#include <vector>

namespace webrtc {

	enum { kNumOfStringLength = 64 };
	enum { kMaxNumOfTlsCertificatesSize = 8 };
    struct rtcConfig
    {
        rtcConfig()
		{
			strcpy(user_agent, "Client v2.0");
		}
        struct Transport {
            Transport()
                :udp_port(5060)
                , tcp_port(5060)
                , tls_port(5061)
			{
				strcpy(bind_addr, "0.0.0.0");
			}
            int udp_port;
            int tcp_port;
            int tls_port;

			char bind_addr[kNumOfStringLength];
        } transport;

        struct Security {
			Security()
			{
				memset(certificate_path, 0, kNumOfStringLength);
				memset(ca_directory, 0, kNumOfStringLength);
				memset(ca_file, 0, kNumOfStringLength);
			}
			char certificate_path[kNumOfStringLength];
			char ca_directory[kNumOfStringLength];
			char ca_file[kNumOfStringLength];

            struct TlsCertificate {
				TlsCertificate()
				{
					memset(tls_domain, 0, kNumOfStringLength);
					memset(tls_cert, 0, kNumOfStringLength);
					memset(tls_private_key, 0, kNumOfStringLength);
					memset(tls_private_key_password, 0, kNumOfStringLength);
				}
				char tls_domain[kNumOfStringLength];
				char tls_cert[kNumOfStringLength];
				char tls_private_key[kNumOfStringLength];
				char tls_private_key_password[kNumOfStringLength];
            };
			TlsCertificate tls_certificates[kMaxNumOfTlsCertificatesSize];
        } security;

        struct MediaOptions {
            MediaOptions()
				:
				turn_server_port(19302),
				stun_server_port(19302),
				rtp_port_start(10000),
				rtp_port_end(65535),
				mtu(1200)
			{
				strcpy(audio_codecs, "opus,isac,g729,pcma,pcmu");
				strcpy(video_codecs, "vp8,vp9,h264,red,ulpfec,rtx");
				strcpy(stun_server, "stun.l.google.com");
				memset(turn_server, 0, kNumOfStringLength);
				memset(turn_username, 0, kNumOfStringLength);
				memset(turn_password, 0, kNumOfStringLength);
			}

            int rtp_port_start;
            int rtp_port_end;

			char stun_server[kNumOfStringLength];
            unsigned short stun_server_port;
			char turn_server[kNumOfStringLength];
            unsigned short turn_server_port;
			char turn_username[kNumOfStringLength];
			char turn_password[kNumOfStringLength];

			char audio_codecs[kNumOfStringLength];
			char video_codecs[kNumOfStringLength];
            int mtu;
        } media_options;

		char user_agent[kNumOfStringLength];

        struct Log
        {
            enum Level
            {
                Crit = 0,
                Err = 1,
                Warning = 2,
                Info = 3,
                Notice = 4,
                Debug = 5,
                Stack = 6
            };

            Log() :
				log_level(Info),
				log_on(false)
			{
				strcpy(sip_trac_file, "sip_trac.txt");
				strcpy(voe_trac_file, "voe_trac.txt");
				strcpy(vie_trac_file, "vie_trac.txt");
			}
            Level log_level;
            bool log_on;
			char sip_trac_file[kNumOfStringLength];
			char voe_trac_file[kNumOfStringLength];
			char vie_trac_file[kNumOfStringLength];
        } log_settings;
    };

};//namespace 



#endif
