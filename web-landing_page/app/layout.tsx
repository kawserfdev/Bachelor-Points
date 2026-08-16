import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";
import { ThemeProvider } from "@/components/theme-provider";

const plusJakartaSans = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
  weight: ["400", "500", "600", "700", "800"],
});

export const metadata: Metadata = {
  title: "BachelorPoints — Smart Bachelor Mess & Meal Management",
  description:
    "Manage your bachelor mess smarter with BachelorPoints. Track meals, bazar expenses, deposits, member balances, duty schedules, and download monthly PDF reports in one simple platform.",
  keywords: [
    "Bachelor Mess Management",
    "Mess Management App Bangladesh",
    "Meal Management App",
    "Bachelor Meal Management",
    "Mess হিসাব",
    "Meal হিসাব",
    "Bazar Management",
    "Mess Expense Tracker",
    "Bachelor Mess App",
    "Hostel Meal Management",
  ],
  authors: [{ name: "BachelorPoints Team" }],
  creator: "BachelorPoints",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://www.bachelorpoints.com/",
    title: "BachelorPoints — Smart Bachelor Mess & Meal Management",
    description:
      "Stop fighting over meal costs. Track meals, manage bazar, record expenses, monitor deposits and calculate balances automatically.",
    siteName: "BachelorPoints",
  },
  twitter: {
    card: "summary_large_image",
    title: "BachelorPoints — Smart Bachelor Mess & Meal Management",
    description:
      "The easiest way to manage your bachelor mess in Bangladesh. Track meals, bazar, expenses, and balances with zero stress.",
  },
  icons: {
    icon: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={cn("h-full", plusJakartaSans.variable, "font-sans")}
    >
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
            (function () {
              try {
                if (localStorage.getItem('bp_authed') === 'true') {
                  window.location.replace('/app/');
                }
              } catch (e) {}
            })();
          `,
          }}
        />
      </head>
      <body className="min-h-full flex flex-col antialiased bg-background text-foreground selection:bg-primary/30">
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
