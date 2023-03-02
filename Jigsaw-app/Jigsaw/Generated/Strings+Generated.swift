// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum AgeGroup {
    public enum AgeGroup {
      public enum Label {
        /// 15-20
        public static let group1520 = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group1520", fallback: "15-20")
        /// 15-
        public static let group15minus = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group15minus", fallback: "15-")
        /// 21-30
        public static let group2130 = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group2130", fallback: "21-30")
        /// 31-40
        public static let group3140 = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group3140", fallback: "31-40")
        /// 41-50
        public static let group4150 = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group4150", fallback: "41-50")
        /// 51-60
        public static let group5160 = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group5160", fallback: "51-60")
        /// 61+
        public static let group61plus = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.group61plus", fallback: "61+")
        /// Prefer not to answer
        public static let unknown = Strings.tr("Localizable", "AgeGroup.AgeGroup.label.unknown", fallback: "Prefer not to answer")
      }
    }
  }
  public enum AnswerCategory {
    public enum AnswerCategory {
      public enum Label {
        /// Correct
        public static let correct = Strings.tr("Localizable", "AnswerCategory.AnswerCategory.label.correct", fallback: "Correct")
        /// Incorrect
        public static let incorrect = Strings.tr("Localizable", "AnswerCategory.AnswerCategory.label.incorrect", fallback: "Incorrect")
        /// Skipped
        public static let skipped = Strings.tr("Localizable", "AnswerCategory.AnswerCategory.label.skipped", fallback: "Skipped")
        /// Unknown
        public static let unknown = Strings.tr("Localizable", "AnswerCategory.AnswerCategory.label.unknown", fallback: "Unknown")
      }
    }
  }
  public enum AppConstants {
    public enum AppConstants {
      /// https://docs.google.com/forms/d/e/1FAIpQLSfgHUhazZeB1pfKQ_i_vSubSkkejVCiXTDz49uRIvUi5QBpYg/viewform
      public static let feedbackFormURL = Strings.tr("Localizable", "AppConstants.AppConstants.feedbackFormURL", fallback: "https://docs.google.com/forms/d/e/1FAIpQLSfgHUhazZeB1pfKQ_i_vSubSkkejVCiXTDz49uRIvUi5QBpYg/viewform")
      /// https://duke.qualtrics.com/jfe/form/SV_eRFROcIlVmfq27I
      public static let surveyURL = Strings.tr("Localizable", "AppConstants.AppConstants.surveyURL", fallback: "https://duke.qualtrics.com/jfe/form/SV_eRFROcIlVmfq27I")
    }
  }
  public enum AppInfo {
    public enum AppInfo {
      /// CFBundleShortVersionString
      public static let versionNumber = Strings.tr("Localizable", "AppInfo.AppInfo.versionNumber", fallback: "CFBundleShortVersionString")
    }
  }
  public enum ChatViewController {
    public enum ConfirmationAlert {
      /// Are you sure you want to exit the chat? If you leave, you will go straight to the quiz and will not be able to come back.
      public static let message = Strings.tr("Localizable", "ChatViewController.confirmationAlert.message", fallback: "Are you sure you want to exit the chat? If you leave, you will go straight to the quiz and will not be able to come back.")
      /// Sure?
      public static let title = Strings.tr("Localizable", "ChatViewController.confirmationAlert.title", fallback: "Sure?")
    }
    public enum MessageInputBar {
      public enum InputTextView {
        /// Type here...
        public static let placeholder = Strings.tr("Localizable", "ChatViewController.messageInputBar.inputTextView.placeholder", fallback: "Type here...")
      }
    }
  }
  public enum DemographicsViewController {
    public enum ViewDidLoad {
      /// Demographics
      public static let title = Strings.tr("Localizable", "DemographicsViewController.viewDidLoad.title", fallback: "Demographics")
    }
  }
  public enum EducationLevel {
    public enum EducationLevel {
      public enum Label {
        /// Some college
        public static let college = Strings.tr("Localizable", "EducationLevel.EducationLevel.label.college", fallback: "Some college")
        /// College graduate
        public static let graduate = Strings.tr("Localizable", "EducationLevel.EducationLevel.label.graduate", fallback: "College graduate")
        /// High school or less
        public static let highSchool = Strings.tr("Localizable", "EducationLevel.EducationLevel.label.highSchool", fallback: "High school or less")
        /// Post graduates
        public static let postGraduate = Strings.tr("Localizable", "EducationLevel.EducationLevel.label.postGraduate", fallback: "Post graduates")
        /// Prefer not to answer
        public static let unknown = Strings.tr("Localizable", "EducationLevel.EducationLevel.label.unknown", fallback: "Prefer not to answer")
      }
    }
  }
  public enum Ethnicity {
    public enum Ethnicity {
      public enum Label {
        /// Asian
        public static let asian = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.asian", fallback: "Asian")
        /// Black or African American
        public static let black = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.black", fallback: "Black or African American")
        /// Hispanic or Latino
        public static let hispanic = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.hispanic", fallback: "Hispanic or Latino")
        /// American Indian or Alaska Native
        public static let native = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.native", fallback: "American Indian or Alaska Native")
        /// Other
        public static let other = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.other", fallback: "Other")
        /// Prefer not to answer
        public static let unknown = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.unknown", fallback: "Prefer not to answer")
        /// White
        public static let white = Strings.tr("Localizable", "Ethnicity.Ethnicity.label.white", fallback: "White")
      }
    }
  }
  public enum Game {
    public enum DecodeQuestionnaireData {
      /// questionType
      public static let questionTypeString = Strings.tr("Localizable", "Game.decodeQuestionnaireData.questionTypeString", fallback: "questionType")
    }
    public enum Init {
      /// backgroundImageURL
      public static let backgroundImageURL = Strings.tr("Localizable", "Game.init.backgroundImageURL", fallback: "backgroundImageURL")
      /// category
      public static let categoryString = Strings.tr("Localizable", "Game.init.categoryString", fallback: "category")
      /// detailText
      public static let detailText = Strings.tr("Localizable", "Game.init.detailText", fallback: "detailText")
      /// gameName
      public static let gameName = Strings.tr("Localizable", "Game.init.gameName", fallback: "gameName")
      /// group1Questionnaires
      public static let group1Questionnaires = Strings.tr("Localizable", "Game.init.group1Questionnaires", fallback: "group1Questionnaires")
      /// group1resourceContents
      public static let group1resourceContents = Strings.tr("Localizable", "Game.init.group1resourceContents", fallback: "group1resourceContents")
      /// group2Questionnaires
      public static let group2Questionnaires = Strings.tr("Localizable", "Game.init.group2Questionnaires", fallback: "group2Questionnaires")
      /// group2resourceContents
      public static let group2resrouceContents = Strings.tr("Localizable", "Game.init.group2resrouceContents", fallback: "group2resourceContents")
      /// introduction
      public static let introductionText = Strings.tr("Localizable", "Game.init.introductionText", fallback: "introduction")
      /// level
      public static let level = Strings.tr("Localizable", "Game.init.level", fallback: "level")
      /// maxAttempts
      public static let maxAttempts = Strings.tr("Localizable", "Game.init.maxAttempts", fallback: "maxAttempts")
      /// version
      public static let version = Strings.tr("Localizable", "Game.init.version", fallback: "version")
    }
  }
  public enum GameCategory {
    public enum GameCategoryClass {
      public enum CollectionView {
        public enum Cell {
          /// GameCollectionCell
          public static let withReuseIdentifier = Strings.tr("Localizable", "GameCategory.GameCategoryClass.collectionView.cell.withReuseIdentifier", fallback: "GameCollectionCell")
        }
      }
    }
    public enum DetailText {
      /// Charter schools are publicly-funded, privately-operated schools.
      public static let charterSchools = Strings.tr("Localizable", "GameCategory.detailText.charterSchools", fallback: "Charter schools are publicly-funded, privately-operated schools.")
      /// Get ready to jump into adventure! Welcome to the exciting world of Jigsaw!
      public static let demo = Strings.tr("Localizable", "GameCategory.detailText.demo", fallback: "Get ready to jump into adventure! Welcome to the exciting world of Jigsaw!")
      /// Charter schools are publicly-funded, privately-operated schools.
      public static let economy = Strings.tr("Localizable", "GameCategory.detailText.economy", fallback: "Charter schools are publicly-funded, privately-operated schools.")
      /// Is it time to get rid of the Electoral College? The United States is unique in using an Electoral College to elect the President.
      public static let environment = Strings.tr("Localizable", "GameCategory.detailText.environment", fallback: "Is it time to get rid of the Electoral College? The United States is unique in using an Electoral College to elect the President.")
      /// Should the government reduce economic inequality by redistributing wealth?
      public static let health = Strings.tr("Localizable", "GameCategory.detailText.health", fallback: "Should the government reduce economic inequality by redistributing wealth?")
      /// Immigration is the international movement of people to a destination country of which they are not natives or where they do not possess citizenship in order to settle as permanent residents or naturalized citizens.
      public static let immigration = Strings.tr("Localizable", "GameCategory.detailText.immigration", fallback: "Immigration is the international movement of people to a destination country of which they are not natives or where they do not possess citizenship in order to settle as permanent residents or naturalized citizens.")
      /// Affirmative action refers to a policy of preferring minorities from underrepresented groups for college admission.
      public static let international = Strings.tr("Localizable", "GameCategory.detailText.international", fallback: "Affirmative action refers to a policy of preferring minorities from underrepresented groups for college admission.")
      /// Minimum wage is the legal minimum hourly wage a person may be paid for their labor.
      public static let justice = Strings.tr("Localizable", "GameCategory.detailText.justice", fallback: "Minimum wage is the legal minimum hourly wage a person may be paid for their labor.")
      /// Minimum wage is the legal minimum hourly wage a person may be paid for their labor.
      public static let minimumWage = Strings.tr("Localizable", "GameCategory.detailText.minimumWage", fallback: "Minimum wage is the legal minimum hourly wage a person may be paid for their labor.")
      /// Lead me to a random topic!
      public static let random = Strings.tr("Localizable", "GameCategory.detailText.random", fallback: "Lead me to a random topic!")
    }
    public enum IconImage {
      /// book
      public static let charterSchools = Strings.tr("Localizable", "GameCategory.iconImage.charterSchools", fallback: "book")
      /// questionmark
      public static let demo = Strings.tr("Localizable", "GameCategory.iconImage.demo", fallback: "questionmark")
      /// books.vertical.fill
      public static let economy = Strings.tr("Localizable", "GameCategory.iconImage.economy", fallback: "books.vertical.fill")
      /// rectangle.badge.checkmark
      public static let environment = Strings.tr("Localizable", "GameCategory.iconImage.environment", fallback: "rectangle.badge.checkmark")
      /// dollarsign.circle
      public static let health = Strings.tr("Localizable", "GameCategory.iconImage.health", fallback: "dollarsign.circle")
      /// shield.lefthalf.fill
      public static let immigration = Strings.tr("Localizable", "GameCategory.iconImage.immigration", fallback: "shield.lefthalf.fill")
      /// equal.circle.fill
      public static let international = Strings.tr("Localizable", "GameCategory.iconImage.international", fallback: "equal.circle.fill")
      /// banknote.fill
      public static let justice = Strings.tr("Localizable", "GameCategory.iconImage.justice", fallback: "banknote.fill")
      /// dollarsign.circle
      public static let minimumWage = Strings.tr("Localizable", "GameCategory.iconImage.minimumWage", fallback: "dollarsign.circle")
      /// questionmark
      public static let random = Strings.tr("Localizable", "GameCategory.iconImage.random", fallback: "questionmark")
    }
    public enum Label {
      /// Charter Schools
      public static let charterSchools = Strings.tr("Localizable", "GameCategory.label.charterSchools", fallback: "Charter Schools")
      /// Demo
      public static let demo = Strings.tr("Localizable", "GameCategory.label.demo", fallback: "Demo")
      /// Charter Schools
      public static let economy = Strings.tr("Localizable", "GameCategory.label.economy", fallback: "Charter Schools")
      /// Electoral College
      public static let environment = Strings.tr("Localizable", "GameCategory.label.environment", fallback: "Electoral College")
      /// Economic Inequality
      public static let health = Strings.tr("Localizable", "GameCategory.label.health", fallback: "Economic Inequality")
      /// Immigration
      public static let immigration = Strings.tr("Localizable", "GameCategory.label.immigration", fallback: "Immigration")
      /// Affirmative Action
      public static let international = Strings.tr("Localizable", "GameCategory.label.international", fallback: "Affirmative Action")
      /// Minimum Wage
      public static let justice = Strings.tr("Localizable", "GameCategory.label.justice", fallback: "Minimum Wage")
      /// Minimum Wage
      public static let minimumWage = Strings.tr("Localizable", "GameCategory.label.minimumWage", fallback: "Minimum Wage")
      /// Random
      public static let random = Strings.tr("Localizable", "GameCategory.label.random", fallback: "Random")
    }
  }
  public enum GameCenterConstants {
    public enum GameCenterConstants {
      /// edu.duke.mobilecenter.JigsawBeta.averageScore
      public static let averageScoreLeaderboardID = Strings.tr("Localizable", "GameCenterConstants.GameCenterConstants.averageScoreLeaderboardID", fallback: "edu.duke.mobilecenter.JigsawBeta.averageScore")
      /// edu.duke.mobilecenter.JigsawBeta.gamesPlayed
      public static let gamesPlayedLeaderboardID = Strings.tr("Localizable", "GameCenterConstants.GameCenterConstants.gamesPlayedLeaderboardID", fallback: "edu.duke.mobilecenter.JigsawBeta.gamesPlayed")
      public enum GetFinishedAchievementID {
        public enum Category {
          /// edu.duke.mobilecenter.JigsawBeta.economyFinished
          public static let economy = Strings.tr("Localizable", "GameCenterConstants.GameCenterConstants.getFinishedAchievementID.category.economy", fallback: "edu.duke.mobilecenter.JigsawBeta.economyFinished")
        }
      }
    }
  }
  public enum GameCenterHelper {
    public enum GameCenterHelper {
      public enum LoadAchievements {
        /// Error: %@
        public static func error(_ p1: Any) -> String {
          return Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.loadAchievements.error", String(describing: p1), fallback: "Error: %@")
        }
      }
      public enum SubmitAverageScore {
        /// ✅ Average score reported.
        public static let `else` = Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitAverageScore.else", fallback: "✅ Average score reported.")
        /// Error: %@
        public static func `if`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitAverageScore.if", String(describing: p1), fallback: "Error: %@")
        }
      }
      public enum SubmitFinishedAchievement {
        /// ✅ Achievement reported for %@
        public static func `else`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitFinishedAchievement.else", String(describing: p1), fallback: "✅ Achievement reported for %@")
        }
        /// Error: %@
        public static func `if`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitFinishedAchievement.if", String(describing: p1), fallback: "Error: %@")
        }
      }
      public enum SubmitGamesPlayed {
        /// ✅ Games played reported.
        public static let `else` = Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitGamesPlayed.else", fallback: "✅ Games played reported.")
        /// Error: %@
        public static func `if`(_ p1: Any) -> String {
          return Strings.tr("Localizable", "GameCenterHelper.GameCenterHelper.submitGamesPlayed.if", String(describing: p1), fallback: "Error: %@")
        }
      }
    }
    public enum Notification {
      public enum Name {
        /// authenticationChanged
        public static let authenticationChanged = Strings.tr("Localizable", "GameCenterHelper.Notification.Name.authenticationChanged", fallback: "authenticationChanged")
      }
    }
  }
  public enum GameError {
    public enum GameError {
      public enum Description {
        /// 😢 You didn't pass the game.
        public static let currentPlayerDropped = Strings.tr("Localizable", "GameError.GameError.description.currentPlayerDropped", fallback: "😢 You didn't pass the game.")
        /// 😞 Max attempts reached.
        public static let maxAttemptReached = Strings.tr("Localizable", "GameError.GameError.description.maxAttemptReached", fallback: "😞 Max attempts reached.")
        /// 😢 Your teammate just quit the game. Please go back to the home screen to find a new teammate.
        public static let otherPlayerDropped = Strings.tr("Localizable", "GameError.GameError.description.otherPlayerDropped", fallback: "😢 Your teammate just quit the game. Please go back to the home screen to find a new teammate.")
        /// 🤨 Your peers didn't pass the room.
        /// Help them and try again!
        public static let otherPlayerFailed = Strings.tr("Localizable", "GameError.GameError.description.otherPlayerFailed", fallback: "🤨 Your peers didn't pass the room.\nHelp them and try again!")
        /// 🤐 Unknown error. Developers are trembling. 🤯
        public static let unknown = Strings.tr("Localizable", "GameError.GameError.description.unknown", fallback: "🤐 Unknown error. Developers are trembling. 🤯")
      }
    }
  }
  public enum GameGroup {
    public enum GameGroup {
      public enum UserScoreString {
        /// @
        public static let  = Strings.tr("Localizable", "GameGroup.GameGroup.userScoreString.@", fallback: "@")
        /// %.6f
        public static func format(_ p1: Float) -> String {
          return Strings.tr("Localizable", "GameGroup.GameGroup.userScoreString.format", p1, fallback: "%.6f")
        }
      }
    }
  }
  public enum GameHistoryTimelineTableViewController {
    public enum ViewDidLoad {
      /// Game History
      public static let title = Strings.tr("Localizable", "GameHistoryTimelineTableViewController.viewDidLoad.title", fallback: "Game History")
    }
  }
  public enum GameStore {
    public enum GameStore {
      public enum CollectionView {
        public enum Cell {
          /// GameCollectionCell
          public static let withReuseIdentifier = Strings.tr("Localizable", "GameStore.GameStore.collectionView.cell.withReuseIdentifier", fallback: "GameCollectionCell")
        }
        public enum Else {
          public enum Cell {
            public enum IconImageView {
              public enum Image {
                /// lock
                public static let systemName = Strings.tr("Localizable", "GameStore.GameStore.collectionView.else.cell.iconImageView.image.systemName", fallback: "lock")
              }
            }
            public enum NameLabel {
              /// ???
              public static let text = Strings.tr("Localizable", "GameStore.GameStore.collectionView.else.cell.nameLabel.text", fallback: "???")
            }
          }
        }
        public enum If {
          public enum Cell {
            public enum IconImageView {
              /// 🎉
              public static let image = Strings.tr("Localizable", "GameStore.GameStore.collectionView.if.cell.iconImageView.image", fallback: "🎉")
            }
          }
        }
      }
    }
  }
  public enum GameViewController {
    public enum ChatroomInstructionStep {
      /// Hi team! You can now chat about what you've just seen.
      /// Remember that different team members have seen different pieces of information, and the whole team needs to know about all of these pieces in order to escape to the next room.
      public static let detailText = Strings.tr("Localizable", "GameViewController.chatroomInstructionStep.detailText", fallback: "Hi team! You can now chat about what you've just seen.\nRemember that different team members have seen different pieces of information, and the whole team needs to know about all of these pieces in order to escape to the next room.")
      /// Chatroom
      public static let title = Strings.tr("Localizable", "GameViewController.chatroomInstructionStep.title", fallback: "Chatroom")
    }
    public enum CreateSurveyTask {
      public enum CompletionStep {
        /// Room Escaped 🎉
        public static let title = Strings.tr("Localizable", "GameViewController.createSurveyTask.completionStep.title", fallback: "Room Escaped 🎉")
      }
    }
    public enum QuestionsInstructionStep {
      /// You will now be quizzed on the information you and your teammate just shared.
      /// You can escape this room if your team answers all of the following questions correctly.
      /// Let's go!🤠
      public static let detailText = Strings.tr("Localizable", "GameViewController.questionsInstructionStep.detailText", fallback: "You will now be quizzed on the information you and your teammate just shared.\nYou can escape this room if your team answers all of the following questions correctly.\nLet's go!🤠")
      /// Quiz
      public static let title = Strings.tr("Localizable", "GameViewController.questionsInstructionStep.title", fallback: "Quiz")
    }
    public enum WaitStep {
      /// Please wait for other players to finish.
      public static let detailText = Strings.tr("Localizable", "GameViewController.waitStep.detailText", fallback: "Please wait for other players to finish.")
      /// Please Wait
      public static let title = Strings.tr("Localizable", "GameViewController.waitStep.title", fallback: "Please Wait")
    }
  }
  public enum Gender {
    public enum Gender {
      public enum Label {
        /// Female
        public static let female = Strings.tr("Localizable", "Gender.Gender.label.female", fallback: "Female")
        /// Male
        public static let male = Strings.tr("Localizable", "Gender.Gender.label.male", fallback: "Male")
        /// Other
        public static let other = Strings.tr("Localizable", "Gender.Gender.label.other", fallback: "Other")
        /// Prefer not to answer
        public static let unknown = Strings.tr("Localizable", "Gender.Gender.label.unknown", fallback: "Prefer not to answer")
      }
    }
  }
  public enum HomeCollectionViewController {
    public enum HandleRandomPerform {
      public enum PresentAlert {
        /// No random game available.
        public static let message = Strings.tr("Localizable", "HomeCollectionViewController.handleRandomPerform.presentAlert.message", fallback: "No random game available.")
        /// Info
        public static let title = Strings.tr("Localizable", "HomeCollectionViewController.handleRandomPerform.presentAlert.title", fallback: "Info")
      }
    }
    public enum NavigationItem {
      /// Issues
      public static let title = Strings.tr("Localizable", "HomeCollectionViewController.navigationItem.title", fallback: "Issues")
    }
  }
  public enum JigsawPiece {
    public enum JigsawPiece {
      public enum BundleName {
        /// jigsaw-green
        public static let green = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.bundleName.green", fallback: "jigsaw-green")
        /// jigsaw-orange
        public static let orange = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.bundleName.orange", fallback: "jigsaw-orange")
        /// jigsaw-purple
        public static let purple = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.bundleName.purple", fallback: "jigsaw-purple")
        /// jigsaw-unknown
        public static let unknown = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.bundleName.unknown", fallback: "jigsaw-unknown")
        /// jigsaw-yellow
        public static let yellow = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.bundleName.yellow", fallback: "jigsaw-yellow")
      }
      public enum Label {
        /// Green piece
        public static let green = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.label.green", fallback: "Green piece")
        /// Orange piece
        public static let orange = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.label.orange", fallback: "Orange piece")
        /// Purple piece
        public static let purple = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.label.purple", fallback: "Purple piece")
        /// Jigsaw piece
        public static let unknown = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.label.unknown", fallback: "Jigsaw piece")
        /// Yellow piece
        public static let yellow = Strings.tr("Localizable", "JigsawPiece.JigsawPiece.label.yellow", fallback: "Yellow piece")
      }
    }
  }
  public enum Message {
    public enum ControlMetaMessage {
      /// ****join****
      public static let join = Strings.tr("Localizable", "Message.ControlMetaMessage.join", fallback: "****join****")
      /// ****leave****
      public static let leave = Strings.tr("Localizable", "Message.ControlMetaMessage.leave", fallback: "****leave****")
      public enum Label {
        /// joined
        public static let join = Strings.tr("Localizable", "Message.ControlMetaMessage.label.join", fallback: "joined")
        /// left
        public static let leave = Strings.tr("Localizable", "Message.ControlMetaMessage.label.leave", fallback: "left")
      }
    }
  }
  public enum MetricsViewController {
    public enum Set1 {
      /// My Scores
      public static let label = Strings.tr("Localizable", "MetricsViewController.set1.label", fallback: "My Scores")
    }
    public enum Set2 {
      /// Jigsaw Average
      public static let label = Strings.tr("Localizable", "MetricsViewController.set2.label", fallback: "Jigsaw Average")
    }
  }
  public enum Onboarding {
    public enum Instruction {
      /// In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!
      public static let detailText = Strings.tr("Localizable", "Onboarding.instruction.detailText", fallback: "In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!")
      /// Localizable.strings
      ///   Jigsaw
      /// 
      ///   Created by Ruitong Su on 1/19/23.
      ///   Copyright © 2023 DukeMobileDevCenter. All rights reserved.
      public static let title = Strings.tr("Localizable", "Onboarding.instruction.title", fallback: "Welcome to Jigsaw Escape!")
    }
  }
  public enum OnboardingSteps {
    public enum OnboardingSteps {
      public enum CompletionStep {
        public enum CompletionStep {
          /// Start playing now!
          public static let detailText = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.completionStep.completionStep.detailText", fallback: "Start playing now!")
          /// All Done
          public static let title = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.completionStep.completionStep.title", fallback: "All Done")
        }
      }
      public enum InformedConsentInstructionStep {
        /// The goal of this game is to escape from a series of rooms by cooperating with your team in information-gathering tasks about a controversial political issue.
        /// 
        public static let detailText = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.detailText", fallback: "The goal of this game is to escape from a series of rooms by cooperating with your team in information-gathering tasks about a controversial political issue.\n")
        /// Before We Start
        public static let title = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.title", fallback: "Before We Start")
        public enum ChatItem {
          /// You will then chat as a team to share the information that each team member has seen.
          public static let text = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.chatItem.text", fallback: "You will then chat as a team to share the information that each team member has seen.")
        }
        public enum InfoItem {
          /// Each member of your team will receive crucial pieces of information about common arguments for positions on the issue.  Each team member will receive bits of information that others do not have.
          public static let text = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.infoItem.text", fallback: "Each member of your team will receive crucial pieces of information about common arguments for positions on the issue.  Each team member will receive bits of information that others do not have.")
        }
        public enum QuizItem {
          /// After chatting, each member of your team  will separately take a short quiz covering all the information gathered and shared by all of your team members.
          public static let text = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.quizItem.text", fallback: "After chatting, each member of your team  will separately take a short quiz covering all the information gathered and shared by all of your team members.")
        }
        public enum RankingItem {
          /// Teams will be ranked on the percentage of quiz questions that the team gets correct. Ties will be broken by how quickly the team was able to move through all of the rooms in this series.
          public static let text = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.rankingItem.text", fallback: "Teams will be ranked on the percentage of quiz questions that the team gets correct. Ties will be broken by how quickly the team was able to move through all of the rooms in this series.")
        }
        public enum RetryItem {
          /// If everyone on your team passes the quiz, then your whole team escapes that room---hurrah!---and you can go on to the next room. If your team does not all pass the quiz, then you will have a chance to go back into the chat to discuss the questions that were missed. Then your team will have another chance to escape the room by each team member passing a quiz on the same quotations.
          public static let text = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.informedConsentInstructionStep.retryItem.text", fallback: "If everyone on your team passes the quiz, then your whole team escapes that room---hurrah!---and you can go on to the next room. If your team does not all pass the quiz, then you will have a chance to go back into the chat to discuss the questions that were missed. Then your team will have another chance to escape the room by each team member passing a quiz on the same quotations.")
        }
      }
      public enum InstructionStep {
        /// In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!
        public static let detailText = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.instructionStep.detailText", fallback: "In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!")
        /// Welcome to Jigsaw Escape!
        public static let title = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.instructionStep.title", fallback: "Welcome to Jigsaw Escape!")
      }
      public enum PoliticalSliderStep {
        public enum PoliticalSliderStep {
          /// Please indicate your political orientation on the slider below.
          public static let question = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.politicalSliderStep.politicalSliderStep.question", fallback: "Please indicate your political orientation on the slider below.")
          /// Jigsaw Value
          public static let title = Strings.tr("Localizable", "OnboardingSteps.OnboardingSteps.politicalSliderStep.politicalSliderStep.title", fallback: "Jigsaw Value")
        }
      }
    }
  }
  public enum ProfileViewController {
    public enum ReloadRows {
      public enum HeaderRow {
        /// ProfileHeaderRow
        public static let tag = Strings.tr("Localizable", "ProfileViewController.reloadRows.headerRow.tag", fallback: "ProfileHeaderRow")
      }
      public enum JigsawValueRow {
        /// JigsawValueRow
        public static let tag = Strings.tr("Localizable", "ProfileViewController.reloadRows.jigsawValueRow.tag", fallback: "JigsawValueRow")
      }
      public enum JoinDateRow {
        /// JoinDateRow
        public static let tag = Strings.tr("Localizable", "ProfileViewController.reloadRows.joinDateRow.tag", fallback: "JoinDateRow")
      }
    }
    public enum UserAccountBarButtonTapped {
      public enum CancelAction {
        /// Cancel
        public static let title = Strings.tr("Localizable", "ProfileViewController.userAccountBarButtonTapped.cancelAction.title", fallback: "Cancel")
      }
      public enum ConnectAction {
        /// Connect Online Account
        public static let title = Strings.tr("Localizable", "ProfileViewController.userAccountBarButtonTapped.connectAction.title", fallback: "Connect Online Account")
      }
      public enum SignOutAction {
        /// Sign Out
        public static let title = Strings.tr("Localizable", "ProfileViewController.userAccountBarButtonTapped.signOutAction.title", fallback: "Sign Out")
        public enum Alert {
          /// Sign out from anonymous account will lose all your data. Please confirm before proceed.
          public static let message = Strings.tr("Localizable", "ProfileViewController.userAccountBarButtonTapped.signOutAction.alert.message", fallback: "Sign out from anonymous account will lose all your data. Please confirm before proceed.")
          /// Be careful
          public static let title = Strings.tr("Localizable", "ProfileViewController.userAccountBarButtonTapped.signOutAction.alert.title", fallback: "Be careful")
        }
      }
    }
    public enum ViewWillAppear {
      public enum HeaderRow {
        /// ProfileHeaderRow
        public static let tag = Strings.tr("Localizable", "ProfileViewController.viewWillAppear.headerRow.tag", fallback: "ProfileHeaderRow")
      }
    }
  }
  public enum QuestionType {
    public enum QuestionType {
      /// BOOLEAN
      public static let boolean = Strings.tr("Localizable", "QuestionType.QuestionType.boolean", fallback: "BOOLEAN")
      /// CONTINUOUS SCALE
      public static let continuousScale = Strings.tr("Localizable", "QuestionType.QuestionType.continuousScale", fallback: "CONTINUOUS SCALE")
      /// INSTRUCTION
      public static let instruction = Strings.tr("Localizable", "QuestionType.QuestionType.instruction", fallback: "INSTRUCTION")
      /// MULTIPLE CHOICE
      public static let multipleChoice = Strings.tr("Localizable", "QuestionType.QuestionType.multipleChoice", fallback: "MULTIPLE CHOICE")
      /// NUMERIC
      public static let numeric = Strings.tr("Localizable", "QuestionType.QuestionType.numeric", fallback: "NUMERIC")
      /// SCALE
      public static let scale = Strings.tr("Localizable", "QuestionType.QuestionType.scale", fallback: "SCALE")
      /// SINGLE CHOICE
      public static let singleChoice = Strings.tr("Localizable", "QuestionType.QuestionType.singleChoice", fallback: "SINGLE CHOICE")
      /// UNKNOWN
      public static let unknown = Strings.tr("Localizable", "QuestionType.QuestionType.unknown", fallback: "UNKNOWN")
    }
  }
  public enum RoomProgressViewController {
    public enum CurrentRoom {
      public enum Broken {
        public enum RoomLevelLabel {
          /// Jigsaw broken 😞
          public static let text = Strings.tr("Localizable", "RoomProgressViewController.currentRoom.broken.roomLevelLabel.text", fallback: "Jigsaw broken 😞")
        }
      }
      public enum GameCompleted {
        public enum RoomLevelLabel {
          /// You've completed the game! 🎉
          public static let text = Strings.tr("Localizable", "RoomProgressViewController.currentRoom.gameCompleted.roomLevelLabel.text", fallback: "You've completed the game! 🎉")
        }
      }
    }
    public enum ViewDidLoad {
      public enum ProgressHUD {
        /// Loading Rooms
        public static let show = Strings.tr("Localizable", "RoomProgressViewController.viewDidLoad.ProgressHUD.show", fallback: "Loading Rooms")
      }
    }
  }
  public enum SignInViewController {
    public enum PlayAnonymouslyButtonTapped {
      public enum Alert {
        /// Playing anonymously might result in losing game records. Connect to one of your online accounts in your profile later.
        public static let message = Strings.tr("Localizable", "SignInViewController.playAnonymouslyButtonTapped.alert.message", fallback: "Playing anonymously might result in losing game records. Connect to one of your online accounts in your profile later.")
        /// Info
        public static let title = Strings.tr("Localizable", "SignInViewController.playAnonymouslyButtonTapped.alert.title", fallback: "Info")
      }
    }
  }
  public enum TeamRankingsViewController {
    public enum TeamRankingsViewController {
      public enum TeamRankingsFooterLabel {
        /// Top 25 teams are displayed.
        public static let text = Strings.tr("Localizable", "TeamRankingsViewController.TeamRankingsViewController.teamRankingsFooterLabel.text", fallback: "Top 25 teams are displayed.")
      }
    }
    public enum PresentAlert {
      /// Placeholder my team
      public static let title = Strings.tr("Localizable", "TeamRankingsViewController.presentAlert.title", fallback: "Placeholder my team")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
