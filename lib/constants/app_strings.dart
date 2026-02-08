/// アプリ内で使用する文字列定数
/// 
/// すべての画面表示テキストをここで一元管理します。
class AppStrings {
  // アプリ情報
  static const String appName = '肥後銀行';
  static const String bankName = '肥後銀行';
  static const String bankTagline = 'うるおいある未来のために、';
  static const String appTagline = 'うるおいある未来のために、';
  static const String appVersion = 'アプリバージョン：2.3.0';

  // 認証関連
  static const String biometricAuthTitle = '生体認証でログイン';
  static const String biometricAuthDescription = 'Touch IDまたはFace IDで認証してください';
  static const String authenticateButton = '認証する';
  static const String passcodeAuthButton = 'パスコードで認証';
  static const String authenticating = '認証中...';
  static const String authenticationFailed = '認証に失敗しました';
  
  // FIDO認証関連
  static const String fidoAuthTitle = 'FIDO認証でログイン';
  static const String fidoAuthDescription = 'Keypasco技術によるセキュアな認証';
  static const String fidoAuthButton = 'FIDO認証する';
  static const String fidoAuthenticating = 'FIDO認証中...';
  static const String fidoAuthFailed = 'FIDO認証に失敗しました';
  
  // 設定画面
  static const String settingsTitle = '設定';
  static const String helpMenu = 'ヘルプ';
  static const String termsMenu = '利用規約';
  static const String accountManagement = 'アカウントの管理';
  static const String deviceManagement = '利用端末の管理';
  static const String passcodeChange = 'パスコードの変更';
  static const String biometricChange = '生体認証の変更';
  static const String fidoAuthChange = 'FIDO認証の変更';
  static const String appExit = 'アプリを終了する';
  static const String withdrawal = '退会の手続き';
  static const String licenses = 'ライセンス';
  
  // FIDO認証設定画面
  static const String fidoSettingsTitle = 'FIDO認証の変更';
  static const String fidoSettingsDescription = 
      'FIDO認証を有効にすると、起動時に生体認証の後、Keypasco技術によるセキュアなFIDO認証が実行されます。';
  static const String fidoAuthLabel = 'FIDO認証';
  static const String fidoAuthSubLabel = '生体認証の後にFIDO認証を実行';
  static const String fidoEnabled = 'FIDO認証を有効にしました';
  static const String fidoDisabled = 'FIDO認証を無効にしました';
  static const String fidoRegistrationSuccess = '登録完了';
  static const String fidoRegistrationSuccessMessage = 
      'FIDO認証が正常に登録されました。\n次回起動時から、生体認証後にFIDO認証が実行されます。';
  
  // FIDO認証説明
  static const String fidoInfoTitle = 'FIDO認証について';
  static const String fidoInfoDescription = 
      '• FIDO2標準に準拠した最先端のパスワードレス認証\n'
      '• Keypasco SDKを使用した高度なセキュリティ\n'
      '• フィッシング攻撃への耐性が高い\n'
      '• 生体情報はデバイス内に安全に保存\n'
      '• サーバーに機密情報が送信されることはありません';
  
  // ホーム画面
  static const String currentTime = '現在';
  static const String balanceDisplay = '残高表示';
  static const String statement = '明細';
  static const String transfer = '振込・振替';
  static const String addAccount = '口座を追加';
  static const String dataRefreshed = 'データを更新しました';
  static const String notificationDemo = '通知（デモ）';
  static const String statementDemo = '明細（デモ）';
  static const String transferDemo = '振込・振替（デモ）';
  static const String addAccountDemo = '口座を追加（デモ）';
  
  // サービスメニュー
  static const String internetBanking = 'インターネット\nバンキング';
  static const String investmentTrust = '投資信託';
  static const String foreignDeposit = '外貨預金';
  static const String foreignCurrency = '外貨預金';
  static const String kyushuFgSecurities = '九州FG証券オン\nライントレード';
  static const String securitiesTrading = '九州FG証券オン\nライントレード';
  static const String kotoraTransfer = 'ことら送金';
  static const String kotraTransfer = 'ことら送金';
  static const String loanApplication = 'ローン申込';
  static const String cardApplication = 'クレジット/\nデビット申込';
  static const String creditDebitCard = 'クレジット/\nデビット申込';
  static const String feeList = '手数料一覧';
  static const String oneTimePassword = 'ワンタイム\nパスワード';
  static const String branchAtmSearch = '店舗・ATM検索';
  static const String contactUs = 'お問い合わせ';
  static const String contact = 'お問い合わせ';
  static const String viewAll = 'すべて見る';
  
  // ボトムナビゲーション
  static const String home = 'ホーム';
  static const String homeTab = 'ホーム';
  static const String registeredAccounts = '登録口座';
  static const String accountsTab = '登録口座';
  static const String services = 'サービス';
  static const String servicesTab = 'サービス';
  
  // 口座情報
  static const String accountType = '普通';
  static const String currencyUnit = '円';
  
  // エラーメッセージ
  static const String errorGeneric = '予期しないエラーが発生しました';
  static const String errorUserNotFound = 'ユーザー情報が取得できません';
  static const String errorRegistrationFailed = 'FIDO認証の登録に失敗しました';
  
  // 確認ダイアログ
  static const String confirmLogout = 'ログアウトしてアプリを終了しますか？';
  static const String confirmButton = 'OK';
  static const String cancelButton = 'キャンセル';
  static const String exitButton = '終了';
  
  // デモメッセージ
  static const String demoMessage = '（デモ）';
}
