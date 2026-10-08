class AppStrings {
  static const String appName = 'আয়-ব্যয়ের হিসাব';
  static const String currencySymbol = '৳';

  // ন্যাভিগেশন
  static const String navHome = 'ড্যাশবোর্ড';
  static const String navTransactions = 'লেনদেন';
  static const String navAnalytics = 'রিপোর্ট';
  static const String navCategories = 'ক্যাটাগরি';
  static const String navProfile = 'প্রোফাইল';

  // ড্যাশবোর্ড
  static const String welcome = 'স্বাগতম';
  static const String totalBalance = 'মোট ব্যালেন্স';
  static const String totalIncome = 'মোট আয়';
  static const String totalExpense = 'মোট ব্যয়';
  static const String recentTransactions = 'সাম্প্রতিক লেনদেন';
  static const String viewAll = 'সব দেখুন';
  static const String noTransactionsYet = 'এখনো কোনো লেনদেন যোগ করা হয়নি';

  // লেনদেন
  static const String tabAll = 'সব';
  static const String tabIncome = 'আয়';
  static const String tabExpense = 'ব্যয়';
  static const String addTransaction = 'নতুন লেনদেন';
  static const String editTransaction = 'লেনদেন পরিবর্তন';
  static const String titleLabel = 'শিরোনাম বা বিবরণ';
  static const String amountLabel = 'টাকার পরিমাণ';
  static const String categoryLabel = 'ক্যাটাগরি নির্বাচন করুন';
  static const String dateLabel = 'তারিখ';
  static const String noteLabel = 'অতিরিক্ত নোট (ঐচ্ছিক)';
  static const String saveBtn = 'সংরক্ষণ করুন';
  static const String updateBtn = 'আপডেট করুন';

  // ফিল্টার
  static const String filterDaily = 'দৈনিক';
  static const String filterWeekly = 'সাপ্তাহিক';
  static const String filterMonthly = 'মাসিক';
  static const String filterYearly = 'বাৎসরিক';
  static const String searchHint = 'লেনদেন খুঁজুন (নাম বা নোট)...';

  // ক্যাটাগরি
  static const String addCategory = 'নতুন ক্যাটাগরি';
  static const String editCategory = 'ক্যাটাগরি পরিবর্তন';
  static const String categoryNameLabel = 'ক্যাটাগরির নাম';
  static const String categoryTypeLabel = 'ক্যাটাগরির ধরন';
  static const String duplicateCategoryError = 'এই ক্যাটাগরি আগে থেকেই তৈরি করা আছে!';
  static const String categoryDeleteWarning = 'এই ক্যাটাগরিতে পূর্বের লেনদেন যুক্ত রয়েছে। ডিলিট করার আগে সেই লেনদেনগুলো অন্য ক্যাটাগরিতে সরিয়ে নিন বা ডিলিট করুন।';

  // ভ্যালিডেশন এরর
  static const String enterTitleError = 'অনুগ্রহ করে একটি শিরোনাম লিখুন';
  static const String enterAmountError = 'সঠিক টাকার পরিমাণ লিখুন (০ থেকে বেশি হতে হবে)';
  static const String selectCategoryError = 'অনুগ্রহ করে একটি ক্যাটাগরি বেছে নিন';

  // মেসেজ
  static const String successSaved = 'সফলভাবে সংরক্ষিত হয়েছে!';
  static const String successUpdated = 'সফলভাবে আপডেট হয়েছে!';
  static const String successDeleted = 'সফলভাবে মুছে ফেলা হয়েছে!';
  static const String confirmDelete = 'আপনি কি নিশ্চিত যে এটি মুছে ফেলতে চান?';
  static const String deleteBtn = 'মুছে ফেলুন';
  static const String cancelBtn = 'বাতিল';
}
