package com.example.hamiltonnhs;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.app.ProgressDialog;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

public class CommitteeMeetings extends Fragment {

    private ProgressDialog progress;
    private WebView webview;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.committee_meetings, container, false);

        webview = (WebView) view.findViewById(R.id.webView);
        webview.loadUrl("https://hamiltonnhs.wixsite.com/hnhs/committees");

        progress = ProgressDialog.show(getActivity(), "Loading...",
                "Processing your request.", true);
        webview.setWebViewClient(new WebViewClient() {

            public void onPageFinished(WebView view, String url) {
                if (progress != null)
                    progress.dismiss();
            }
        });

        // Enable Javascript
        WebSettings webSettings = webview.getSettings();
        webSettings.setJavaScriptEnabled(true);

        // Force links and redirects to open in the WebView instead of in a browser
        webview.getSettings().setBuiltInZoomControls(true);
        webview.getSettings().setDisplayZoomControls(false);

        return view;
    }
}
