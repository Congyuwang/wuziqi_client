use flutter_rust_bridge::support::IntoDartExceptPrimitive;

#[derive(Clone)]
pub enum SingleState {
    /// black
    B,
    /// white
    W,
    /// empty
    E,
}

impl IntoDartExceptPrimitive for SingleState {}

#[derive(Clone)]
pub struct FieldRow {
    pub columns: Vec<SingleState>,
}

#[derive(Clone)]
pub struct Field {
    pub latest_x: Option<i32>,
    pub latest_y: Option<i32>,
    pub rows: Vec<FieldRow>,
}

#[derive(Clone)]
pub enum Color {
    Black,
    White,
}

pub enum ConnectionInitError {
    IpMaxConnExceed,
    ConnectionClosed,
    UserNameNotReceived,
    UserNameTooLong,
    UserNameExists,
    InvalidUserName,
    NetworkError(ConnectionError),
}

pub enum ConnectionError {
    /// Attempting to send or receive over-sized data payload
    MaxDataLengthExceeded,
    /// Cannot decode message type
    UnknownMessageType,
    /// checksum incorrect
    DataCorrupted,
    /// `TryFrom<&[u8]>` returned error
    DecodeError,
    /// Cannot decode error message
    UnknownError,
}

pub struct RoomToken(pub String);

#[derive(Clone)]
pub struct SessionConfig {
    pub undo_request_timeout: u64,
    pub undo_dialogue_extra_seconds: u64,
    pub play_timeout: u64,
}

pub enum Messages {
    /// send bytes to player
    ToPlayer { name: String, msg: Vec<u8> },
    /// search online players name
    /// will return `PlayerList` with player names
    /// that contains the required `name`
    /// if `name` is null, random player names are returned
    SearchOnlinePlayers { name: Option<String>, limit: u8 },
    /// send user name
    UserName(String),
    /// create a new room
    CreateRoom(SessionConfig),
    /// attempt to join a room with a RoomToken
    JoinRoom(RoomToken),
    /// Quit a room
    QuitRoom,
    /// when in a Room, get ready for a game session
    Ready,
    /// reverse `ready`
    Unready,
    /// play a position in game [0, 15). Out of bounds are ignored.
    /// Repeatedly playing on an occupied position will result in `GameError`.
    Play { x: u8, y: u8 },
    /// request undo in game.
    RequestUndo,
    /// approve undo requests in game.
    ApproveUndo,
    /// reject undo requests in game.
    RejectUndo,
    /// quit game session (only quit this round).
    QuitGameSession,
    /// chat message
    SendChatMessage(String),
    /// exit game (quit game and room), close connection
    /// exiting game without sending `ExitGame` signal is considered `Disconnected`
    ExitGame,
    /// client error: other errors excluding network error
    ClientError(String),
}

pub enum RoomState {
    Empty,
    OpponentIsReady(String),
    OpponentIsNotReady(String),
}

pub enum Responses {
    FromPlayer {
        name: String,
        msg: Vec<u8>,
    },
    PlayerList(Vec<String>),
    /// Connection success
    ConnectionSuccess,
    /// Connection Init Error
    ConnectionInitFailure(ConnectionInitError),
    /// response to `CreateRoom`
    RoomCreated(String),
    /// response to `JoinRoom`
    /// the two fields are correspondingly
    /// `room` token
    JoinRoomSuccess {
        token: String,
        room_state: RoomState,
    },
    /// response to `JoinRoom`
    JoinRoomFailureTokenNotFound,
    /// response to `JoinRoom`
    JoinRoomFailureRoomFull,
    /// when the other player gets `JoinRoomSuccess`
    /// the `String` is the username
    OpponentJoinRoom(String),
    /// when the other player `QuitRoom`
    OpponentQuitRoom,
    /// when the other player is `Ready`
    OpponentReady,
    /// when the other play does `Unready`
    OpponentUnready,
    /// when both players are `Ready`
    GameStarted(Color),
    /// update field
    FieldUpdate(Field),
    /// opponent request undo
    UndoRequest,
    /// undo rejected by timeout
    UndoTimeoutRejected,
    /// undo rejected due to synchronization reason
    UndoAutoRejected,
    /// undo approved
    Undo(Field),
    /// undo rejected by opponent
    UndoRejectedByOpponent,
    /// game session ends, black timeout
    GameEndBlackTimeout,
    /// game session ends, white timeout
    GameEndWhiteTimeout,
    /// game session ends, black wins
    GameEndBlackWins,
    /// game session ends, white wins
    GameEndWhiteWins,
    /// game session ends, draw
    GameEndDraw,
    /// Room score information (player1, player2)
    RoomScores {
        player1_name: String,
        player1_score: i32,
        player2_name: String,
        player2_score: i32,
    },
    /// opponent quit game session
    OpponentQuitGameSession,
    /// opponent exit game
    OpponentExitGame,
    /// opponent disconnected
    OpponentDisconnected,
    /// game session ends in error
    GameSessionError(String),
    /// ChatMessage: (user_name, message)
    ChatMessage {
        name: String,
        msg: String,
    },
}

impl TryFrom<Vec<u8>> for Responses {
    type Error = anyhow::Error;

    fn try_from(value: Vec<u8>) -> std::result::Result<Self, Self::Error> {
        match wuziqi::Responses::try_from(value) {
            Ok(rsp) => Ok(rsp.into()),
            Err(e) => Err(e),
        }
    }
}

impl Into<Vec<u8>> for Messages {
    fn into(self) -> Vec<u8> {
        let message: wuziqi::Messages = self.into();
        message.into()
    }
}

impl Into<wuziqi::SessionConfig> for SessionConfig {
    fn into(self) -> wuziqi::SessionConfig {
        wuziqi::SessionConfig {
            undo_request_timeout: self.undo_request_timeout,
            undo_dialogue_extra_seconds: self.undo_dialogue_extra_seconds,
            play_timeout: self.play_timeout,
        }
    }
}

impl Into<wuziqi::RoomToken> for RoomToken {
    /// this function may panic.
    /// do not use illegal RoomToken
    fn into(self) -> wuziqi::RoomToken {
        wuziqi::RoomToken::from_code(&self.0).unwrap()
    }
}

impl Into<wuziqi::Messages> for Messages {
    fn into(self) -> wuziqi::Messages {
        match self {
            Messages::SearchOnlinePlayers { name, limit } => {
                wuziqi::Messages::SearchOnlinePlayers(name, limit)
            }
            Messages::ToPlayer { name, msg } => wuziqi::Messages::ToPlayer(name, msg),
            Messages::UserName(name) => wuziqi::Messages::UserName(name),
            Messages::CreateRoom(config) => wuziqi::Messages::CreateRoom(config.into()),
            Messages::JoinRoom(token) => wuziqi::Messages::JoinRoom(token.into()),
            Messages::QuitRoom => wuziqi::Messages::QuitRoom,
            Messages::Ready => wuziqi::Messages::Ready,
            Messages::Unready => wuziqi::Messages::Unready,
            Messages::Play { x, y } => wuziqi::Messages::Play(x, y),
            Messages::RequestUndo => wuziqi::Messages::RequestUndo,
            Messages::ApproveUndo => wuziqi::Messages::ApproveUndo,
            Messages::RejectUndo => wuziqi::Messages::RejectUndo,
            Messages::QuitGameSession => wuziqi::Messages::QuitGameSession,
            Messages::SendChatMessage(msg) => wuziqi::Messages::ChatMessage(msg),
            Messages::ExitGame => wuziqi::Messages::ExitGame,
            Messages::ClientError(e) => wuziqi::Messages::ClientError(e),
        }
    }
}

impl From<wuziqi::ConnectionError> for ConnectionError {
    fn from(e: wuziqi::ConnectionError) -> Self {
        match e {
            wuziqi::ConnectionError::MaxDataLengthExceeded => {
                ConnectionError::MaxDataLengthExceeded
            }
            wuziqi::ConnectionError::UnknownMessageType => ConnectionError::UnknownMessageType,
            wuziqi::ConnectionError::DataCorrupted => ConnectionError::DataCorrupted,
            wuziqi::ConnectionError::DecodeError => ConnectionError::DecodeError,
            wuziqi::ConnectionError::UnknownError => ConnectionError::UnknownError,
        }
    }
}

impl From<wuziqi::ConnectionInitError> for ConnectionInitError {
    fn from(e: wuziqi::ConnectionInitError) -> Self {
        match e {
            wuziqi::ConnectionInitError::IpMaxConnExceed => ConnectionInitError::IpMaxConnExceed,
            wuziqi::ConnectionInitError::ConnectionClosed => ConnectionInitError::ConnectionClosed,
            wuziqi::ConnectionInitError::UserNameNotReceived => {
                ConnectionInitError::UserNameNotReceived
            }
            wuziqi::ConnectionInitError::UserNameTooLong => ConnectionInitError::UserNameTooLong,
            wuziqi::ConnectionInitError::UserNameExists => ConnectionInitError::UserNameExists,
            wuziqi::ConnectionInitError::InvalidUserName => ConnectionInitError::InvalidUserName,
            wuziqi::ConnectionInitError::NetworkError(e) => {
                ConnectionInitError::NetworkError(e.into())
            }
        }
    }
}

impl From<wuziqi::RoomState> for RoomState {
    fn from(s: wuziqi::RoomState) -> Self {
        match s {
            wuziqi::RoomState::Empty => RoomState::Empty,
            wuziqi::RoomState::OpponentReady(name) => RoomState::OpponentIsReady(name),
            wuziqi::RoomState::OpponentUnready(name) => RoomState::OpponentIsNotReady(name),
        }
    }
}

impl From<wuziqi::Color> for Color {
    fn from(c: wuziqi::Color) -> Self {
        match c {
            wuziqi::Color::Black => Color::Black,
            wuziqi::Color::White => Color::White,
        }
    }
}

impl From<wuziqi::State> for SingleState {
    fn from(s: wuziqi::State) -> Self {
        match s {
            wuziqi::State::B => SingleState::B,
            wuziqi::State::W => SingleState::W,
            wuziqi::State::E => SingleState::E,
        }
    }
}

impl From<wuziqi::FieldState> for Field {
    fn from(f: wuziqi::FieldState) -> Self {
        let field = f
            .field
            .map(|row| FieldRow {
                columns: row.map(|s| s.into()).to_vec(),
            })
            .to_vec();
        Field {
            latest_x: Some(f.latest.0 as i32),
            latest_y: Some(f.latest.1 as i32),
            rows: field,
        }
    }
}

impl From<wuziqi::FieldStateNullable> for Field {
    fn from(f: wuziqi::FieldStateNullable) -> Self {
        let latest = f.latest;
        let field = f
            .field
            .map(|row| FieldRow {
                columns: row.map(|s| s.into()).to_vec(),
            })
            .to_vec();
        if let Some(latest) = latest {
            Field {
                latest_x: Some(latest.0 as i32),
                latest_y: Some(latest.1 as i32),
                rows: field,
            }
        } else {
            Field {
                latest_x: None,
                latest_y: None,
                rows: field,
            }
        }
    }
}

impl From<wuziqi::Responses> for Responses {
    fn from(rsp: wuziqi::Responses) -> Self {
        match rsp {
            wuziqi::Responses::FromPlayer(name, msg) => Responses::FromPlayer { name, msg },
            wuziqi::Responses::PlayerList(names) => Responses::PlayerList(names),
            wuziqi::Responses::ConnectionSuccess => Responses::ConnectionSuccess,
            wuziqi::Responses::ConnectionInitFailure(e) => {
                Responses::ConnectionInitFailure(e.into())
            }
            wuziqi::Responses::RoomCreated(token) => Responses::RoomCreated(token),
            wuziqi::Responses::JoinRoomSuccess(token, state) => Responses::JoinRoomSuccess {
                token,
                room_state: state.into(),
            },
            wuziqi::Responses::JoinRoomFailureTokenNotFound => {
                Responses::JoinRoomFailureTokenNotFound
            }
            wuziqi::Responses::JoinRoomFailureRoomFull => Responses::JoinRoomFailureRoomFull,
            wuziqi::Responses::OpponentJoinRoom(name) => Responses::OpponentJoinRoom(name),
            wuziqi::Responses::OpponentQuitRoom => Responses::OpponentQuitRoom,
            wuziqi::Responses::OpponentReady => Responses::OpponentReady,
            wuziqi::Responses::OpponentUnready => Responses::OpponentUnready,
            wuziqi::Responses::GameStarted(color) => Responses::GameStarted(color.into()),
            wuziqi::Responses::FieldUpdate(f) => Responses::FieldUpdate(f.into()),
            wuziqi::Responses::UndoRequest => Responses::UndoRequest,
            wuziqi::Responses::UndoTimeoutRejected => Responses::UndoTimeoutRejected,
            wuziqi::Responses::UndoAutoRejected => Responses::UndoAutoRejected,
            wuziqi::Responses::Undo(f) => Responses::Undo(f.into()),
            wuziqi::Responses::UndoRejectedByOpponent => Responses::UndoRejectedByOpponent,
            wuziqi::Responses::GameEndBlackTimeout => Responses::GameEndBlackTimeout,
            wuziqi::Responses::GameEndWhiteTimeout => Responses::GameEndWhiteTimeout,
            wuziqi::Responses::GameEndBlackWins => Responses::GameEndBlackWins,
            wuziqi::Responses::GameEndWhiteWins => Responses::GameEndWhiteWins,
            wuziqi::Responses::GameEndDraw => Responses::GameEndDraw,
            wuziqi::Responses::RoomScores(x, y) => Responses::RoomScores {
                player1_name: x.0,
                player1_score: x.1 as i32,
                player2_name: y.0,
                player2_score: y.1 as i32,
            },
            wuziqi::Responses::OpponentQuitGameSession => Responses::OpponentQuitGameSession,
            wuziqi::Responses::OpponentExitGame => Responses::OpponentExitGame,
            wuziqi::Responses::OpponentDisconnected => Responses::OpponentDisconnected,
            wuziqi::Responses::GameSessionError(e) => Responses::GameSessionError(e),
            wuziqi::Responses::ChatMessage(name, msg) => Responses::ChatMessage { name, msg },
        }
    }
}
