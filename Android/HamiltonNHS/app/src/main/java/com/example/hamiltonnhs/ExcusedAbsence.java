package com.example.hamiltonnhs;

import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.DatePicker;
import android.widget.TextView;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.Calendar;
import java.util.HashMap;
import java.text.SimpleDateFormat;
import java.text.DateFormat;

public class ExcusedAbsence extends Fragment implements OnClickListener{

    private static final String TAG = "Excused Absence";

    private TextView mDisplayDate;
    private DatePickerDialog.OnDateSetListener mDateSetListener;
    private DatabaseReference ref;

    private Button submit;
    private TextInputEditText name;
    private TextInputLayout reason;

    private String date;
    private String studentID;
    HashMap<String, String> pushData;

    private ProgressDialog progress;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.excused_absence, container, false);

        studentID = getActivity().getIntent().getExtras().getString(LoginActivity.ARG_FROM_MAIN);

        ref = FirebaseDatabase.getInstance().getReference();
        pushData = new HashMap<String, String>();

        name = view.findViewById(R.id.nameinput);
        reason = view.findViewById(R.id.reasoninput);
        mDisplayDate = view.findViewById(R.id.datepicker);
        submit = view.findViewById(R.id.submit_absence);
        submit.setOnClickListener(this);
        showDate();

        return view;
    }

    private void showDate()
    {
        mDisplayDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Calendar cal = Calendar.getInstance();
                int year = cal.get(Calendar.YEAR);
                int month = cal.get(Calendar.MONTH);
                int day = cal.get(Calendar.DAY_OF_MONTH);

                DatePickerDialog dialog = new DatePickerDialog(
                        getActivity(),
                        android.R.style.Theme_Holo_Light_Dialog_MinWidth,
                        mDateSetListener,
                        year, month, day);
                dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
                dialog.show();
            }
        });

        mDateSetListener = new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker datePicker, int year, int month, int day) {
                month += 1;
                Log.d(TAG, "onDate: mm/dd/yyyy: " + month + "/" + day + "/" + year);

                date = month + "/" + day + "/" + year;
                mDisplayDate.setText(date);
            }
        };
    }

    private boolean validateName()
    {
        String nameInput = name.getEditableText().toString().trim();

        if(nameInput.isEmpty())
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

    private boolean validateReason()
    {
        String reasonInput = reason.getEditText().getText().toString().trim();

        if(reasonInput.isEmpty())
        {
            reason.setError("Not a valid reason");
            return false;
        }
        else
        {
            reason.setError(null);
            return true;
        }
    }


    @Override
    public void onClick(View v) {
        progress = ProgressDialog.show(getActivity(), "Loading...",
                "Processing your request.", true);

        if(!validateName()|!validateReason())
        {
            progress.dismiss();
            return;
        }

        if(date == null)
        {
            DateFormat df = new SimpleDateFormat("MM/dd/yyyy");
            date = df.format(Calendar.getInstance().getTime());
        }

        pushData.put("Data", date);
        pushData.put("ID", studentID);
        pushData.put("Name", name.getEditableText().toString());
        pushData.put("Reason", reason.getEditText().getText().toString());

        ref.child("Excused Absences").push().setValue(pushData);

        name.getText().clear();
        reason.getEditText().getText().clear();

        progress.dismiss();

        Toast.makeText(getActivity(), "Success!", Toast.LENGTH_LONG).show();
    }
}