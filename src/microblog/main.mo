import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
    public type Message = {
        msg: Text;
        time: Time.Time;
    };

    public type Microblog = actor {
        follow: shared(Principal) -> async (); // 添加关注对象
        follows: shared query () -> async [Principal]; // 返回关注列表
        post: shared (Text) -> async (Time.Time); // 发布新消息
        posts: shared query (Time.Time) -> async [Message]; // 返回所有发布的消息
        timeline : shared query (Time.Time) -> async [Message]; // 返回所有关注对象发布的消息
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal) : async () {
        followed := List.push(id, followed);
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post(text: Text) : async (Time.Time) {
        assert(Principal.toText(msg.caller) == "xs74a-gvqqk-3ncef-n3hyo-4azlz-q2pcm-hltti-o6rjd-ebl5f-x3ixn-gae");
        messages := List.push<Message>({
            msg = text;
            time = Time.now();
        }, messages);
        Time.now();
    };

    public shared func posts(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        for(msg in Iter.fromList(messages)){
            if(msg.time > since) {
                all := List.push({msg = msg.msg; time = msg.time;}, all);
            };
        };
        List.toArray<Message>(all);
    };

    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        for(id in Iter.fromList(followed)) {
            let canister : Microblog = actor (Principal.toText(id));
            let msgs = await canister.posts(since);
            for(msg in Iter.fromArray(msgs)) {
                all := List.push({msg = msg.msg; time = msg.time;}, all);
            };
        };
        List.toArray(all);
    };
};
