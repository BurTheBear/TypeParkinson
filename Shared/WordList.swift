import Foundation

/// Common English words, roughly most frequent first, weighted towards
/// everyday messages. The decoder's language model: a word's rank is its prior.
/// Any other word the system dictionary knows is still allowed, just less likely.
enum WordList {
    static let ranks: [String: Int] = {
        var ranks: [String: Int] = [:]
        for (index, word) in words.split(separator: " ").enumerated() where ranks[String(word)] == nil {
            ranks[String(word)] = index
        }
        return ranks
    }()

    static let words = """
    the to and a i you it of in is that for on my me be have with this your we are not at so do can but \
    just was get if all what will go no up out like know about one good love time there now see they how \
    when he she her him his them our us an as or by from day today tomorrow tonight thanks thank yes okay \
    ok please home call text back here want need got going come think make let well really then too much \
    more very had has would could should did were been some any been sorry great nice happy see soon later \
    morning afternoon evening night week weekend dinner lunch breakfast coffee tea doctor appointment \
    work new way first last next two three four five ten minutes hour hours long little big still also \
    only right left take give tell say said ask feel feeling better best help need hope sure maybe \
    because after before again always never ever something nothing everything anything someone everyone \
    people family friend friends mom dad son daughter wife husband kids children grandma grandpa brother \
    sister baby name man woman life world house car store park walk drive ride bus train meet meeting \
    church game watch tv phone email message picture photo photos send sent bring brought pick pickup \
    milk bread eggs food water dinner cook made make making eat ate drink sleep slept tired rest pills \
    medicine pharmacy hospital nurse visit visiting birthday card gift party celebrate christmas holiday \
    weather rain sunny cold hot warm nice beautiful lovely wonderful fine good bad sad glad miss missed \
    love loved loves hug kisses talk talked talking speak spoke listen heard hear read reading write \
    writing wrote typed type typing keyboard keys hands hand fingers today's yesterday monday tuesday \
    wednesday thursday friday saturday sunday january february march april may june july august \
    september october november december year years month months days ago early late lately soon \
    where why who which whose what's that's it's i'm i'll i've don't can't won't didn't isn't doesn't \
    wasn't you're we're they're let's there's here's he's she's couldn't wouldn't shouldn't haven't \
    on my way running few minutes almost there wait waiting ready done finished start started stop \
    open close closed door window room kitchen garden yard dog cat bird walk walked walking ran run \
    running past old mill cup sits sit sat stand stood library noon town city school class teacher \
    lesson book books paper news movie music song songs play played playing team win won lose lost \
    money pay paid buy bought sell sold price cheap shop shopping list need needs needed want wants \
    wanted look looked looking looks seem seems seemed find found keep kept leave left put show showed \
    try tried trying use used using turn turned move moved live lived living believe hold held bring \
    happen happened write provide sit stand lose pay meet include continue set learn change lead \
    understand watch follow stop create spend grow open walk offer remember consider appear buy wait \
    serve die send expect build stay fall cut reach kill remain suggest raise pass sell require report \
    decide pull break broke thing things place part case point fact group problem number system \
    question government company program area state hand eye job word words business issue side kind \
    head service friend power hour game line end member law car city community name president team \
    minute idea body information nothing back parent face others level office door health person art \
    war history party result change morning reason research girl guy moment air teacher force \
    education foot boy age policy process music market sense nation plan college interest death \
    experience effect class control care field development role effort rate heart drug show leader light \
    voice police mind price report decision son view relationship town road arm difference value \
    building action model season society tax director position player record paper space ground form \
    event official matter center couple site project activity star table need court american oil \
    situation cost industry figure street image phone data picture practice piece land product doctor \
    wall patient worker news test movie north love support technology step baby computer type \
    attention film tree source organization hair window evidence population site range camera west \
    hope hospital church trial event bed brother sister quite enough pretty probably actually \
    especially usually sometimes often already almost together alone else instead though although \
    however while since until unless whether either neither both each every few many most other \
    another such same different important possible able free full sure whole real own true clear \
    easy hard simple short high low large small young old early late public private local special \
    certain major human recent personal open available current national natural physical similar \
    simple strong ready social political economic serious final main green red blue white black \
    yellow brown gray orange purple pink dark light bright quiet loud slow fast quick careful \
    gentle kind sweet funny smart busy calm safe strange worried excited proud lucky healthy sick \
    hurt pain fell fall dizzy shaky steady stiff slow tremor exercise exercises walk stretch therapy \
    appointment clinic checkup results tablets dose refill prescription insurance bill bills bank \
    mail package delivery delivered arrive arrived leaving left coming came going went get got \
    give gave take took see saw know knew think thought tell told become became begin began \
    feel felt try call called ask asked work worked seem seemed help helped talk talked turn \
    start started show showed hear heard play played run move moved like liked live lived \
    believe believed happen happened include included hello hi hey bye goodbye goodnight \
    congratulations welcome cheers xoxo lol haha omg btw fyi asap thx pls tmrw
    """
}
