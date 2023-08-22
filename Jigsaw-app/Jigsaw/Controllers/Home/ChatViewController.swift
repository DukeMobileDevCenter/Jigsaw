//
//  ChatViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import Photos

// Firebase User, FireStore realtime database, object storage
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Chatroom UI
import MessageKit
import InputBarAccessoryView
import PINRemoteImage
import Agrume

// Profanity Filter

let botMsg = ["Hi, I'm a bot. How can I assist you?",
              "Thank you for contacting us. How can I help you today?",
              "I'm here to help. What can I do for you?",
              "Please let me know how can I assist you today.",
              "Hello! How may I be of assistance?",
              "Welcome! I'm here to help. What can I do for you?",
              "How can I assist you today? Let me know!",
              "Hello there! How may I help you today?",
              "Greetings! What can I help you with?",
              "Hi, I'm an AI assistant. What do you need help with?",
              "Hi there! I'm here to assist you. How can I help?"]
// List of Words taken from : https://www.cs.cmu.edu/~biglou/resources/bad-words.txt
let profaneWordList = ["abbo", "abo", "abortion", "abuse", "addict", "addicts", "adult", "africa", "african", "alla", "allah", "alligatorbait", "amateur", "american", "anal", "analannie", "analsex", "angie", "angry", "anus", "arab", "arabs", "areola", "argie", "aroused", "arse", "arsehole", "asian", "ass", "assassin", "assassinate", "assassination", "assault", "assbagger", "assblaster", "assclown", "asscowboy", "asses", "assfuck", "assfucker", "asshat", "asshole", "assholes", "asshore", "assjockey", "asskiss", "asskisser", "assklown", "asslick", "asslicker", "asslover", "assman", "assmonkey", "assmunch", "assmuncher", "asspacker", "asspirate", "asspuppies", "assranger", "asswhore", "asswipe", "athletesfoot", "attack", "australian", "babe", "babies", "backdoor", "backdoorman", "backseat", "badfuck", "balllicker", "balls", "ballsack", "banging", "baptist", "barelylegal", "barf", "barface", "barfface", "bast", "bastard ", "bazongas", "bazooms", "beaner", "beast", "beastality", "beastial", "beastiality", "beatoff", "beat-off", "beatyourmeat", "beaver", "bestial", "bestiality", "bi", "biatch", "bible", "bicurious", "bigass", "bigbastard", "bigbutt", "bigger", "bisexual", "bi-sexual", "bitch", "bitcher", "bitches", "bitchez", "bitchin", "bitching", "bitchslap", "bitchy", "biteme", "black", "blackman", "blackout", "blacks", "blind", "blow", "blowjob", "boang", "bogan", "bohunk", "bollick", "bollock", "bomb", "bombers", "bombing", "bombs", "bomd", "bondage", "boner", "bong", "boob", "boobies", "boobs", "booby", "boody", "boom", "boong", "boonga", "boonie", "booty", "bootycall", "bountybar", "bra", "brea5t", "breast", "breastjob", "breastlover", "breastman", "brothel", "bugger", "buggered", "buggery", "bullcrap", "bulldike", "bulldyke", "bullshit", "bumblefuck", "bumfuck", "bunga", "bunghole", "buried", "burn", "butchbabes", "butchdike", "butchdyke", "butt", "buttbang", "butt-bang", "buttface", "buttfuck", "butt-fuck", "buttfucker", "butt-fucker", "buttfuckers", "butt-fuckers", "butthead", "buttman", "buttmunch", "buttmuncher", "buttpirate", "buttplug", "buttstain", "byatch", "cacker", "cameljockey", "cameltoe", "canadian", "cancer", "carpetmuncher", "carruth", "catholic", "catholics", "cemetery", "chav", "cherrypopper", "chickslick", "children's", "chin", "chinaman", "chinamen", "chinese", "chink", "chinky", "choad", "chode", "christ", "christian", "church", "cigarette", "cigs", "clamdigger", "clamdiver", "clit", "clitoris", "clogwog", "cocaine", "cock", "cockblock", "cockblocker", "cockcowboy", "cockfight", "cockhead", "cockknob", "cocklicker", "cocklover", "cocknob", "cockqueen", "cockrider", "cocksman", "cocksmith", "cocksmoker", "cocksucer", "cocksuck ", "cocksucked ", "cocksucker", "cocksucking", "cocktail", "cocktease", "cocky", "cohee", "coitus", "color", "colored", "coloured", "commie", "communist", "condom", "conservative", "conspiracy", "coolie", "cooly", "coon", "coondog", "copulate", "cornhole", "corruption", "cra5h", "crabs", "crack", "crackpipe", "crackwhore", "crack-whore", "crap", "crapola", "crapper", "crappy", "crash", "creamy", "crime", "crimes", "criminal", "criminals", "crotch", "crotchjockey", "crotchmonkey", "crotchrot", "cum", "cumbubble", "cumfest", "cumjockey", "cumm", "cummer", "cumming", "cumquat", "cumqueen", "cumshot", "cunilingus", "cunillingus", "cunn", "cunnilingus", "cunntt", "cunt", "cunteyed", "cuntfuck", "cuntfucker", "cuntlick ", "cuntlicker ", "cuntlicking ", "cuntsucker", "cybersex", "cyberslimer", "dago", "dahmer", "dammit", "damn", "damnation", "damnit", "darkie", "darky", "datnigga", "dead", "deapthroat", "death", "deepthroat", "defecate", "dego", "demon", "deposit", "desire", "destroy", "deth", "devil", "devilworshipper", "dick", "dickbrain", "dickforbrains", "dickhead", "dickless", "dicklick", "dicklicker", "dickman", "dickwad", "dickweed", "diddle", "die", "died", "dies", "dike", "dildo", "dingleberry", "dink", "dipshit", "dipstick", "dirty", "disease", "diseases", "disturbed", "dive", "dix", "dixiedike", "dixiedyke", "doggiestyle", "doggystyle", "dong", "doodoo", "doo-doo", "doom", "dope", "dragqueen", "dragqween", "dripdick", "drug", "drunk", "drunken", "dumb", "dumbass", "dumbbitch", "dumbfuck", "dyefly", "dyke", "easyslut", "eatballs", "eatme", "eatpussy", "ecstacy", "ejaculate", "ejaculated", "ejaculating ", "ejaculation", "enema", "enemy", "erect", "erection", "ero", "escort", "ethiopian", "ethnic", "european", "evl", "excrement", "execute", "executed", "execution", "executioner", "explosion", "facefucker", "faeces", "fag", "fagging", "faggot", "fagot", "failed", "failure", "fairies", "fairy", "faith", "fannyfucker", "fart", "farted ", "farting ", "farty ", "fastfuck", "fat", "fatah", "fatass", "fatfuck", "fatfucker", "fatso", "fckcum", "fear", "feces", "felatio ", "felch", "felcher", "felching", "fellatio", "feltch", "feltcher", "feltching", "fetish", "fight", "filipina", "filipino", "fingerfood", "fingerfuck ", "fingerfucked ", "fingerfucker ", "fingerfuckers", "fingerfucking ", "fire", "firing", "fister", "fistfuck", "fistfucked ", "fistfucker ", "fistfucking ", "fisting", "flange", "flasher", "flatulence", "floo", "flydie", "flydye", "fok", "fondle", "footaction", "footfuck", "footfucker", "footlicker", "footstar", "fore", "foreskin", "forni", "fornicate", "foursome", "fourtwenty", "fraud", "freakfuck", "freakyfucker", "freefuck", "fu", "fubar", "fuc", "fucck", "fuck", "fucka", "fuckable", "fuckbag", "fuckbuddy", "fucked", "fuckedup", "fucker", "fuckers", "fuckface", "fuckfest", "fuckfreak", "fuckfriend", "fuckhead", "fuckher", "fuckin", "fuckina", "fucking", "fuckingbitch", "fuckinnuts", "fuckinright", "fuckit", "fuckknob", "fuckme ", "fuckmehard", "fuckmonkey", "fuckoff", "fuckpig", "fucks", "fucktard", "fuckwhore", "fuckyou", "fudgepacker", "fugly", "fuk", "fuks", "funeral", "funfuck", "fungus", "fuuck", "gangbang", "gangbanged ", "gangbanger", "gangsta", "gatorbait", "gay", "gaymuthafuckinwhore", "gaysex ", "geez", "geezer", "geni", "genital", "german", "getiton", "gin", "ginzo", "gipp", "girls", "givehead", "glazeddonut", "gob", "god", "godammit", "goddamit", "goddammit", "goddamn", "goddamned", "goddamnes", "goddamnit", "goddamnmuthafucker", "goldenshower", "gonorrehea", "gonzagas", "gook", "gotohell", "goy", "goyim", "greaseball", "gringo", "groe", "gross", "grostulation", "gubba", "gummer", "gun", "gyp", "gypo", "gypp", "gyppie", "gyppo", "gyppy", "hamas", "handjob", "hapa", "harder", "hardon", "harem", "headfuck", "headlights", "hebe", "heeb", "hell", "henhouse", "heroin", "herpes", "heterosexual", "hijack", "hijacker", "hijacking", "hillbillies", "hindoo", "hiscock", "hitler", "hitlerism", "hitlerist", "hiv", "ho", "hobo", "hodgie", "hoes", "hole", "holestuffer", "homicide", "homo", "homobangers", "homosexual", "honger", "honk", "honkers", "honkey", "honky", "hook", "hooker", "hookers", "hooters", "hore", "hork", "horn", "horney", "horniest", "horny", "horseshit", "hosejob", "hoser", "hostage", "hotdamn", "hotpussy", "hottotrot", "hummer", "husky", "hussy", "hustler", "hymen", "hymie", "iblowu", "idiot", "ikey", "illegal", "incest", "insest", "intercourse", "interracial", "intheass", "inthebuff", "israel", "israeli", "israel's", "italiano", "itch", "jackass", "jackoff", "jackshit", "jacktheripper", "jade", "jap", "japanese", "japcrap", "jebus", "jeez", "jerkoff", "jesus", "jesuschrist", "jew", "jewish", "jiga", "jigaboo", "jigg", "jigga", "jiggabo", "jigger ", "jiggy", "jihad", "jijjiboo", "jimfish", "jism", "jiz ", "jizim", "jizjuice", "jizm ", "jizz", "jizzim", "jizzum", "joint", "juggalo", "jugs", "junglebunny", "kaffer", "kaffir", "kaffre", "kafir", "kanake", "kid", "kigger", "kike", "kill", "killed", "killer", "killing", "kills", "kink", "kinky", "kissass", "kkk", "knife", "knockers", "kock", "kondum", "koon", "kotex", "krap", "krappy", "kraut", "kum", "kumbubble", "kumbullbe", "kummer", "kumming", "kumquat", "kums", "kunilingus", "kunnilingus", "kunt", "ky", "kyke", "lactate", "laid", "lapdance", "latin", "lesbain", "lesbayn", "lesbian", "lesbin", "lesbo", "lez", "lezbe", "lezbefriends", "lezbo", "lezz", "lezzo", "liberal", "libido", "licker", "lickme", "lies", "limey", "limpdick", "limy", "lingerie", "liquor", "livesex", "loadedgun", "lolita", "looser", "loser", "lotion", "lovebone", "lovegoo", "lovegun", "lovejuice", "lovemuscle", "lovepistol", "loverocket", "lowlife", "lsd", "lubejob", "lucifer", "luckycammeltoe", "lugan", "lynch", "macaca", "mad", "mafia", "magicwand", "mams", "manhater", "manpaste", "marijuana", "mastabate", "mastabater", "masterbate", "masterblaster", "mastrabator", "masturbate", "masturbating", "mattressprincess", "meatbeatter", "meatrack", "meth", "mexican", "mgger", "mggor", "mickeyfinn", "mideast", "milf", "minority", "mockey", "mockie", "mocky", "mofo", "moky", "moles", "molest", "molestation", "molester", "molestor", "moneyshot", "mooncricket", "mormon", "moron", "moslem", "mosshead", "mothafuck", "mothafucka", "mothafuckaz", "mothafucked ", "mothafucker", "mothafuckin", "mothafucking ", "mothafuckings", "motherfuck", "motherfucked", "motherfucker", "motherfuckin", "motherfucking", "motherfuckings", "motherlovebone", "muff", "muffdive", "muffdiver", "muffindiver", "mufflikcer", "mulatto", "muncher", "munt", "murder", "murderer", "muslim", "naked", "narcotic", "nasty", "nastybitch", "nastyho", "nastyslut", "nastywhore", "nazi", "necro", "negro", "negroes", "negroid", "negro's", "nig", "niger", "nigerian", "nigerians", "nigg", "nigga", "niggah", "niggaracci", "niggard", "niggarded", "niggarding", "niggardliness", "niggardliness's", "niggardly", "niggards", "niggard's", "niggaz", "nigger", "niggerhead", "niggerhole", "niggers", "nigger's", "niggle", "niggled", "niggles", "niggling", "nigglings", "niggor", "niggur", "niglet", "nignog", "nigr", "nigra", "nigre", "nip", "nipple", "nipplering", "nittit", "nlgger", "nlggor", "nofuckingway", "nook", "nookey", "nookie", "noonan", "nooner", "nude", "nudger", "nuke", "nutfucker", "nymph", "ontherag", "oral", "orga", "orgasim ", "orgasm", "orgies", "orgy", "osama", "paki", "palesimian", "palestinian", "pansies", "pansy", "panti", "panties", "payo", "pearlnecklace", "peck", "pecker", "peckerwood", "pee", "peehole", "pee-pee", "peepshow", "peepshpw", "pendy", "penetration", "peni5", "penile", "penis", "penises", "penthouse", "period", "perv", "phonesex", "phuk", "phuked", "phuking", "phukked", "phukking", "phungky", "phuq", "pi55", "picaninny", "piccaninny", "pickaninny", "piker", "pikey", "piky", "pimp", "pimped", "pimper", "pimpjuic", "pimpjuice", "pimpsimp", "pindick", "piss", "pissed", "pisser", "pisses ", "pisshead", "pissin ", "pissing", "pissoff ", "pistol", "pixie", "pixy", "playboy", "playgirl", "pocha", "pocho", "pocketpool", "pohm", "polack", "pom", "pommie", "pommy", "poo", "poon", "poontang", "poop", "pooper", "pooperscooper", "pooping", "poorwhitetrash", "popimp", "porchmonkey", "porn", "pornflick", "pornking", "porno", "pornography", "pornprincess", "pot", "poverty", "premature", "pric", "prick", "prickhead", "primetime", "propaganda", "pros", "prostitute", "protestant", "pu55i", "pu55y", "pube", "pubic", "pubiclice", "pud", "pudboy", "pudd", "puddboy", "puke", "puntang", "purinapricness", "puss", "pussie", "pussies", "pussy", "pussycat", "pussyeater", "pussyfucker", "pussylicker", "pussylips", "pussylover", "pussypounder", "pusy", "quashie", "queef", "queer", "quickie", "quim", "ra8s", "rabbi", "racial", "racist", "radical", "radicals", "raghead", "randy", "rape", "raped", "raper", "rapist", "rearend", "rearentry", "rectum", "redlight", "redneck", "reefer", "reestie", "refugee", "reject", "remains", "rentafuck", "republican", "rere", "retard", "retarded", "ribbed", "rigger", "rimjob", "rimming", "roach", "robber", "roundeye", "rump", "russki", "russkie", "sadis", "sadom", "samckdaddy", "sandm", "sandnigger", "satan", "scag", "scallywag", "scat", "schlong", "screw", "screwyou", "scrotum", "scum", "semen", "seppo", "servant", "sex", "sexed", "sexfarm", "sexhound", "sexhouse", "sexing", "sexkitten", "sexpot", "sexslave", "sextogo", "sextoy", "sextoys", "sexual", "sexually", "sexwhore", "sexy", "sexymoma", "sexy-slim", "shag", "shaggin", "shagging", "shat", "shav", "shawtypimp", "sheeney", "shhit", "shinola", "shit", "shitcan", "shitdick", "shite", "shiteater", "shited", "shitface", "shitfaced", "shitfit", "shitforbrains", "shitfuck", "shitfucker", "shitfull", "shithapens", "shithappens", "shithead", "shithouse", "shiting", "shitlist", "shitola", "shitoutofluck", "shits", "shitstain", "shitted", "shitter", "shitting", "shitty ", "shoot", "shooting", "shortfuck", "showtime", "sick", "sissy", "sixsixsix", "sixtynine", "sixtyniner", "skank", "skankbitch", "skankfuck", "skankwhore", "skanky", "skankybitch", "skankywhore", "skinflute", "skum", "skumbag", "slant", "slanteye", "slapper", "slaughter", "slav", "slave", "slavedriver", "sleezebag", "sleezeball", "slideitin", "slime", "slimeball", "slimebucket", "slopehead", "slopey", "slopy", "slut", "sluts", "slutt", "slutting", "slutty", "slutwear", "slutwhore", "smack", "smackthemonkey", "smut", "snatch", "snatchpatch", "snigger", "sniggered", "sniggering", "sniggers", "snigger's", "sniper", "snot", "snowback", "snownigger", "sob", "sodom", "sodomise", "sodomite", "sodomize", "sodomy", "sonofabitch", "sonofbitch", "sooty", "sos", "soviet", "spaghettibender", "spaghettinigger", "spank", "spankthemonkey", "sperm", "spermacide", "spermbag", "spermhearder", "spermherder", "spic", "spick", "spig", "spigotty", "spik", "spit", "spitter", "splittail", "spooge", "spreadeagle", "spunk", "spunky", "squaw", "stagg", "stiffy", "strapon", "stringer", "stripclub", "stroke", "stroking", "stupid", "stupidfuck", "stupidfucker", "suck", "suckdick", "sucker", "suckme", "suckmyass", "suckmydick", "suckmytit", "suckoff", "suicide", "swallow", "swallower", "swalow", "swastika", "sweetness", "syphilis", "taboo", "taff", "tampon", "tang", "tantra", "tarbaby", "tard", "teat", "terror", "terrorist", "teste", "testicle", "testicles", "thicklips", "thirdeye", "thirdleg", "threesome", "threeway", "timbernigger", "tinkle", "tit", "titbitnipply", "titfuck", "titfucker", "titfuckin", "titjob", "titlicker", "titlover", "tits", "tittie", "titties", "titty", "tnt", "toilet", "tongethruster", "tongue", "tonguethrust", "tonguetramp", "tortur", "torture", "tosser", "towelhead", "trailertrash", "tramp", "trannie", "tranny", "transexual", "transsexual", "transvestite", "triplex", "trisexual", "trojan", "trots", "tuckahoe", "tunneloflove", "turd", "turnon", "twat", "twink", "twinkie", "twobitwhore", "uck", "uk", "unfuckable", "upskirt", "uptheass", "upthebutt", "urinary", "urinate", "urine", "usama", "uterus", "vagina", "vaginal", "vatican", "vibr", "vibrater", "vibrator", "vietcong", "violence", "virgin", "virginbreaker", "vomit", "vulva", "wab", "wank", "wanker", "wanking", "waysted", "weapon", "weenie", "weewee", "welcher", "welfare", "wetb", "wetback", "wetspot", "whacker", "whash", "whigger", "whiskey", "whiskeydick", "whiskydick", "whit", "whitenigger", "whites", "whitetrash", "whitey", "whiz", "whop", "whore", "whorefucker", "whorehouse", "wigger", "willie", "williewanker", "willy", "wn", "wog", "women's", "wop", "wtf", "wuss", "wuzzie", "xtc", "xxx", "yankee", "yellowman", "zigabo", "zipperhead"]

class ChatViewController: MessagesViewController {
    // MARK: Properties
    
    /// An array of chatroom users, set by the parent view controller.
    var chatroomUserIDs = [String]()
    
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                // Disable user interaction when sending photo.
                self.messageInputBar.isUserInteractionEnabled = !self.isSendingPhoto
                // Set the bar to semi-transparent when sending photo.
                self.messageInputBar.alpha = !self.isSendingPhoto ? 1 : 0.5
            }
        }
    }
    /// A reference to the chatroom messages collection.
    private var messagesReference: CollectionReference?
    /// A listener to the messages collection.
    private var messageListener: ListenerRegistration?
    /// The current user in the chatroom.
    private let user: User
    /// The current chatroom struct.
    private let chatroom: Chatroom
    /// An array to hold all chat messages.
    private var chatMessages = [Message]()
    /// Enter demo game
    private var isDemo: Bool
    /// Current room for a game.
    var currentGameRoom: Int?
    /// Game Currently being played by the player
    var gameOfMyGroup: GameOfGroup?
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    // MARK: Initializers
    
    deinit {
        messageListener?.remove()
        os_log(.info, "✅ chatroom deinit")
    }
    
    init(user: User, chatroom: Chatroom, isDemo: Bool = false) {
        self.user = user
        self.chatroom = chatroom
        self.isDemo = isDemo
        super.init(nibName: nil, bundle: nil)
        title = chatroom.name
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add a join message to the chatroom.
        sendControlMessage(type: .join)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc
    func back(sender: UIBarButtonItem) {
        let confirmationAlert = UIAlertController(title: Strings.ChatViewController.ConfirmationAlert.title, message: Strings.ChatViewController.ConfirmationAlert.message, preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.sendControlMessage(type: .leave)
            self.navigationController?.popViewController(animated: true)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = chatroom.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Quiz", style: .plain, target: self, action: #selector(ChatViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        messagesReference = FirebaseConstants.chatroomMessagesRef(chatroomID: id)
        
        messageListener = messagesReference?.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.inputTextView.placeholder = Strings.ChatViewController.MessageInputBar.InputTextView.placeholder
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        /*
         let cameraItem = InputBarButtonItem(type: .system)
         cameraItem.image = UIImage(systemName: "camera")
         cameraItem.addTarget(
         self,
         action: #selector(cameraButtonPressed),
         for: .primaryActionTriggered
         )
         cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
         */
        //      messageInputBar.leftStackView.alignment = .center
        //     messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        //       messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    // MARK: - Actions
    /*
     @objc
     private func cameraButtonPressed(_ sender: InputBarButtonItem) {
     let picker = UIImagePickerController()
     picker.delegate = self
     picker.sourceType = .photoLibrary
     present(picker, animated: true, completion: nil)
     }*/
}

// MARK: - Helpers
func binarySearch<T:Comparable>(_ inputArr:Array<T>, _ searchItem: T) -> Int? {
    var lowerIndex = 0
    var upperIndex = inputArr.count - 1
    
    while (true) {
        let currentIndex = (lowerIndex + upperIndex)/2
        if(inputArr[currentIndex] == searchItem) {
            return currentIndex
        } else if (lowerIndex > upperIndex) {
            return nil
        } else {
            if (inputArr[currentIndex] > searchItem) {
                upperIndex = currentIndex - 1
            } else {
                lowerIndex = currentIndex + 1
            }
        }
    }
}

extension ChatViewController {
    private func getUserPiece(uid: String) -> JigsawPiece {
        let piece: JigsawPiece
        if let currentUserIndex = chatroomUserIDs.firstIndex(of: uid) {
            piece = JigsawPiece(index: currentUserIndex)
        } else {
            piece = .unknown
        }
        return piece
    }
    
    private func getMetaMessage(at indexPath: IndexPath) -> ControlMetaMessage? {
        let message = chatMessages[indexPath.section]
        return ControlMetaMessage(rawValue: message.content)
    }
    
    private func save(_ message: Message) {
        messagesReference?.addDocument(data: message.representation) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
                return
            }
            self.messagesCollectionView.scrollToLastItem()
            self.messageInputBar.sendButton.stopAnimating()
        }
    }
    
    private func didReceiveUserMessage() {
        let robot = ChatUser(senderId: "robot", displayName: "Robot", jigsawValue: Profiles.jigsawValue)
        srand48(Int(Date().timeIntervalSince1970))
        let randomNumber = Int(arc4random_uniform(UInt32(botMsg.count)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            guard let gameOfMyGroup = self.gameOfMyGroup else{                return
            }
            
            guard let demoGameChatbotMessages = demoChatbotMessages[gameOfMyGroup.gameName] else{
                return
            }
            
            guard let messageContent = demoGameChatbotMessages[self.currentGameRoom!] else{
                return
            }
            
            let robotMsg = Message(user: robot, content: messageContent)
            
            self.chatMessages.append(robotMsg)
            self.chatMessages.sort()
            
            let isLatestMessage2 = self.chatMessages.firstIndex(of: robotMsg) == (self.chatMessages.count - 1)
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    /// This function filters the message for objectionable words using the
    /// `censorWordList` as a reference.
    /// - Parameter message: Message that is currently being sent
    /// - Returns: Message with filtered content
    private func censorMessage(_ message: Message) -> Message{
        // Create a new message with the filtered content
        
        var messageContentStr: String = message.content
        var messageContentStrList = messageContentStr.components(separatedBy: CharacterSet.whitespaces)
        for i in 0..<messageContentStrList.capacity{
            if(binarySearch(profaneWordList, messageContentStrList[i].lowercased()) != nil){
                messageContentStrList[i] = "****"
            }
        }
        messageContentStr = String(messageContentStrList.joined(by: " "))
        var newMessage: Message = Message(message: message, content: messageContentStr)
        return newMessage
    }
    
    private func insertNewMessage(_ message: Message) {
        // Anti network jitter.
        guard !chatMessages.contains(message) else { return }
        
        let newMessage = censorMessage(message)
        chatMessages.append(newMessage)
        chatMessages.sort()
        
        let isLatestMessage = chatMessages.firstIndex(of: message) == (chatMessages.count - 1)
        
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            insertNewMessage(message)
        default:
            break
        }
    }
    /*
     private func uploadImage(_ image: UIImage, to channel: Chatroom, completion: @escaping (URL?) -> Void) {
     guard let channelID = channel.id else {
     completion(nil)
     return
     }
     
     guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.UIImageJPEGRepresentation(compressionQuality: 0.4) else {
     completion(nil)
     return
     }
     
     let metadata = StorageMetadata()
     metadata.contentType = "image/jpeg"
     
     let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
     let imageRef = FirebaseConstants.chatroomStorage.child(channelID).child(imageName)
     imageRef.putData(data, metadata: metadata) { metadata, _ in
     guard metadata != nil else {
     completion(nil)
     return
     }
     // Async fetch the download URL.
     imageRef.downloadURL { url, _ in
     completion(url)
     }
     }
     }
     
     private func sendPhoto(_ image: UIImage) {
     isSendingPhoto = true
     
     uploadImage(image, to: chatroom) { [weak self] url in
     guard let self = self, let url = url else { return }
     self.isSendingPhoto = false
     
     let message = Message(user: self.user, imageURL: url)
     self.save(message)
     self.messagesCollectionView.scrollToBottom()
     }
     }
     */
    private func sendControlMessage(type: ControlMetaMessage) {
        let message = Message(user: user, controlMetaMessage: type)
        save(message)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if getMetaMessage(at: indexPath) != nil {
            return UIColor.darkGray
        }
        
        return isFromCurrentSender(message: message) ? messagesCollectionView.tintColor : .systemGray3
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if getMetaMessage(at: indexPath) != nil {
            return .bubble
        }
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            imageView.pin_updateWithProgress = true
            imageView.pin_setImage(from: media.url)
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let piece = getUserPiece(uid: message.sender.senderId)
        avatarView.setImage(UIImage(named: piece.bundleName)!)
        avatarView.backgroundColor = .clear
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 8)
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    /// Dismiss the keyboard when tapping on the background.
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    /// Preview the image with Argume when tapping an image.
    func didTapImage(in cell: MessageCollectionViewCell) {
        let message = messageForItem(at: messagesCollectionView.indexPath(for: cell)!, in: messagesCollectionView)
        switch message.kind {
        case .photo(let media):
            let agrume = Agrume(url: media.url!)
            agrume.background = .blurred(.regular)
            agrume.show(from: self)
        default:
            break
        }
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        let piece = getUserPiece(uid: user.uid)
        return ChatUser(senderId: user.uid, displayName: piece.label, jigsawValue: Profiles.jigsawValue)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        chatMessages.count
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        chatMessages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = chatMessages[indexPath.section]
        let piece = getUserPiece(uid: message.sender.senderId)
        if let metaMessage = ControlMetaMessage(rawValue: message.content) {
            // Replace the control message with emoji.
            let content: String
            switch metaMessage {
            case .join:
                content = "\(piece.label) has joined the chat"
            case .leave:
                content = "\(piece.label) has left the chat to take the quiz"
            }
            
            let attributedContent = NSMutableAttributedString(string: content)
            attributedContent.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: NSRange(location: 0, length: NSString.init(string: content).length))
            attributedContent.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: NSRange(location: 0, length: NSString.init(string: content).length))
            return Message(message: message, content: content, kind: .attributedText(attributedContent))
        } else {
            return message
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // If no control data, display time every 10 messages.
        if indexPath.section % 10 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        // Otherwise, do not display cell top label.
        return nil
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // Display control metadata.
        switch message.kind {
        case .text:
            if getMetaMessage(at: indexPath) != nil {
                return UIFont.systemFont(ofSize: 16).capHeight * 2
            }
        default:
            break
        }
        // Display send date.
        if indexPath.section % 10 == 0 {
            return UIFont.boldSystemFont(ofSize: 16).capHeight * 2
        }
        // Do not display top label.
        return 0
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let senderPiece = getUserPiece(uid: message.sender.senderId)
        return NSAttributedString(
            string: senderPiece.label,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.systemGray3
            ]
        )
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        UIFont.preferredFont(forTextStyle: .caption1).capHeight * 2
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageInputBar.sendButton.startAnimating()
        let message = Message(user: user, content: text)
        save(message)
        // Clear the input field after sending the message.
        inputBar.inputTextView.text = ""
        // bot chat
        if isDemo {
            didReceiveUserMessage()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
/*
 extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
 picker.dismiss(animated: true, completion: nil)
 if let asset = info[.phAsset] as? PHAsset { // 1
 let size = CGSize(width: 500, height: 500)
 PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, _ in
 guard let image = result else {
 return
 }
 self.sendPhoto(image)
 }
 } else if let image = info[.originalImage] as? UIImage { // 2
 sendPhoto(image)
 }
 }
 
 func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
 picker.dismiss(animated: true, completion: nil)
 }
 }
 */
