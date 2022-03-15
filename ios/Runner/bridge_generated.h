#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct Messages_ToPlayer {
  struct wire_uint_8_list *name;
  struct wire_uint_8_list *msg;
} Messages_ToPlayer;

typedef struct Messages_SearchOnlinePlayers {
  struct wire_uint_8_list *name;
  uint8_t limit;
} Messages_SearchOnlinePlayers;

typedef struct Messages_UserName {
  struct wire_uint_8_list *field0;
} Messages_UserName;

typedef struct wire_SessionConfig {
  uint64_t undo_request_timeout;
  uint64_t undo_dialogue_extra_seconds;
  uint64_t play_timeout;
} wire_SessionConfig;

typedef struct Messages_CreateRoom {
  struct wire_SessionConfig *field0;
} Messages_CreateRoom;

typedef struct wire_RoomToken {
  struct wire_uint_8_list *field0;
} wire_RoomToken;

typedef struct Messages_JoinRoom {
  struct wire_RoomToken *field0;
} Messages_JoinRoom;

typedef struct Messages_QuitRoom {

} Messages_QuitRoom;

typedef struct Messages_Ready {

} Messages_Ready;

typedef struct Messages_Unready {

} Messages_Unready;

typedef struct Messages_Play {
  uint8_t x;
  uint8_t y;
} Messages_Play;

typedef struct Messages_RequestUndo {

} Messages_RequestUndo;

typedef struct Messages_ApproveUndo {

} Messages_ApproveUndo;

typedef struct Messages_RejectUndo {

} Messages_RejectUndo;

typedef struct Messages_QuitGameSession {

} Messages_QuitGameSession;

typedef struct Messages_SendChatMessage {
  struct wire_uint_8_list *field0;
} Messages_SendChatMessage;

typedef struct Messages_ExitGame {

} Messages_ExitGame;

typedef struct Messages_ClientError {
  struct wire_uint_8_list *field0;
} Messages_ClientError;

typedef union MessagesKind {
  struct Messages_ToPlayer *ToPlayer;
  struct Messages_SearchOnlinePlayers *SearchOnlinePlayers;
  struct Messages_UserName *UserName;
  struct Messages_CreateRoom *CreateRoom;
  struct Messages_JoinRoom *JoinRoom;
  struct Messages_QuitRoom *QuitRoom;
  struct Messages_Ready *Ready;
  struct Messages_Unready *Unready;
  struct Messages_Play *Play;
  struct Messages_RequestUndo *RequestUndo;
  struct Messages_ApproveUndo *ApproveUndo;
  struct Messages_RejectUndo *RejectUndo;
  struct Messages_QuitGameSession *QuitGameSession;
  struct Messages_SendChatMessage *SendChatMessage;
  struct Messages_ExitGame *ExitGame;
  struct Messages_ClientError *ClientError;
} MessagesKind;

typedef struct wire_Messages {
  int32_t tag;
  union MessagesKind *kind;
} wire_Messages;

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_connect_to_server(int64_t port_,
                            uint8_t a,
                            uint8_t b,
                            uint8_t c,
                            uint8_t d,
                            uint16_t server_port,
                            struct wire_uint_8_list *user_name);

void wire_send(int64_t port_, struct wire_Messages *msg);

void wire_empty_field(int64_t port_);

void wire_default_session_config(int64_t port_);

void wire_set_undo_request_timeout(int64_t port_, struct wire_SessionConfig *config, uint64_t secs);

void wire_set_undo_dialogue_extra_seconds(int64_t port_,
                                          struct wire_SessionConfig *config,
                                          uint64_t secs);

void wire_set_play_timeout(int64_t port_, struct wire_SessionConfig *config, uint64_t secs);

struct wire_Messages *new_box_autoadd_messages(void);

struct wire_RoomToken *new_box_autoadd_room_token(void);

struct wire_SessionConfig *new_box_autoadd_session_config(void);

struct wire_uint_8_list *new_uint_8_list(int32_t len);

union MessagesKind *inflate_Messages_ToPlayer(void);

union MessagesKind *inflate_Messages_SearchOnlinePlayers(void);

union MessagesKind *inflate_Messages_UserName(void);

union MessagesKind *inflate_Messages_CreateRoom(void);

union MessagesKind *inflate_Messages_JoinRoom(void);

union MessagesKind *inflate_Messages_Play(void);

union MessagesKind *inflate_Messages_SendChatMessage(void);

union MessagesKind *inflate_Messages_ClientError(void);

void free_WireSyncReturnStruct(struct WireSyncReturnStruct val);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_connect_to_server);
    dummy_var ^= ((int64_t) (void*) wire_send);
    dummy_var ^= ((int64_t) (void*) wire_empty_field);
    dummy_var ^= ((int64_t) (void*) wire_default_session_config);
    dummy_var ^= ((int64_t) (void*) wire_set_undo_request_timeout);
    dummy_var ^= ((int64_t) (void*) wire_set_undo_dialogue_extra_seconds);
    dummy_var ^= ((int64_t) (void*) wire_set_play_timeout);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_messages);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_room_token);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_session_config);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_ToPlayer);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_SearchOnlinePlayers);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_UserName);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_CreateRoom);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_JoinRoom);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_Play);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_SendChatMessage);
    dummy_var ^= ((int64_t) (void*) inflate_Messages_ClientError);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}