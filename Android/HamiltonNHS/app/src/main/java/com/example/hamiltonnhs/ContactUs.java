package com.example.hamiltonnhs;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Toast;
import android.widget.Button;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.HashMap;


public class ContactUs extends Fragment implements OnClickListener {

    private static final String TAG = "Contact Us";

    private TextInputEditText name;
    private TextInputEditText email;
    private TextInputEditText subject;
    private TextInputLayout message;

    private Button submit;

    private String studentID;
    HashMap<String, String> pushData;
    private ProgressDialog progress;

    private DatabaseReference ref;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.contact_us, container, false);

        ref = FirebaseDatabase.getInstance().getReference();

        name = view.findViewById(R.id.nameinput);
        email = view.findViewById(R.id.emailinput);
        subject = view.findViewById(R.id.subjectinput);
        message = view.findViewById(R.id.messageinput);
        submit = view.findViewById(R.id.submit);

        studentID = getActivity().getIntent().getExtras().getString(LoginActivity.ARG_FROM_MAIN);

        pushData = new HashMap<String, String>();

        submit.setOnClickListener(this);

        return view;
    }

    private boolean validateName()
    {
        String nameinput = name.getEditableText().toString().trim();

        if(nameinput.isEmpty())
        {
            name.setError("Not a valid name");
            return false;
        }
        else
        {
            name.setError(null);
            return true;
        }
    }

    private boolean validateEmail()
    {
        String emailinput = email.getEditableText().toString().trim();

        if(emailinput.isEmpty())
        {
            email.setError("Not a valid email");
            return false;
        }
        else
        {
            email.setError(null);
            return true;
        }
    }

    private boolean validateSubject()
    {
        String subjectinput = subject.getEditableText().toString().trim();

        if(subjectinput.isEmpty())
        {
            subject.setError("Not a valid name");
            return false;
        }
        else
        {
            subject.setError(null);
            return true;
        }
    }

    private boolean validateMessage()
    {
        String messageinput = message.getEditText().getText().toString().trim();

        if(messageinput.isEmpty())
        {
            message.setError("Not a valid name");
            return false;
        }
        else
        {
            message.setError(null);
            return true;
        }
    }

    @Override
    public void onClick(View v) {
        progress = ProgressDialog.show(getActivity(), "Loading...",
                "Processing your request.", true);

        if(!validateName()|!validateEmail()|!validateSubject()|!validateMessage())
        {
            progress.dismiss();
            return;
        }

        pushData.put("Email", email.getEditableText().toString());
        pushData.put("Message", message.getEditText().getText().toString());
        pushData.put("Name", name.getEditableText().toString());
        pushData.put("Subject", subject.getEditableText().toString());

        ref.child("Contact").push().setValue(pushData);

        email.getText().clear();
        message.getEditText().getText().clear();
        name.getText().clear();
        subject.getText().clear();

        progress.dismiss();

        Toast.makeText(getActivity(), "Success!", Toast.LENGTH_LONG).show();
    }
}