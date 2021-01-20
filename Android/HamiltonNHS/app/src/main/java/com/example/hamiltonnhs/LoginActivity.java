package com.example.hamiltonnhs;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.content.DialogInterface;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.textfield.TextInputLayout;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class LoginActivity extends AppCompatActivity {

    private TextInputLayout studentIDinput;
    private DatabaseReference ref;

    private ProgressDialog progress;

    public static final String ARG_FROM_MAIN = "arg";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login);
        getSupportActionBar().hide();

        ref = FirebaseDatabase.getInstance().getReference();

        studentIDinput = findViewById(R.id.id_input);
    }

    public void confirmInput(View v)
    {
        final String IDinput = studentIDinput.getEditText().getText().toString().trim();

        progress = ProgressDialog.show(this, "Loading...",
                "Processing your request.", true);

        ref.child("Students").addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if(dataSnapshot.exists())
                {
                    if(studentIDinput.getEditText().getText().toString().isEmpty()) {
                        Log.d("Input", "Empty");
                    }
                    else if(!dataSnapshot.hasChild(studentIDinput.getEditText().getText().toString()) && !studentIDinput.getEditText().getText().toString().isEmpty())
                    {
                        studentIDinput.setError("Student ID does not exist");
                    }
                    else if(Integer.parseInt(dataSnapshot.child(IDinput).child("Strikes").getValue().toString()) >= 3)
                    {
                        AlertDialog.Builder alertDialog = new AlertDialog.Builder(LoginActivity.this);
                        alertDialog.setTitle("Error");
                        alertDialog.setMessage("You have been banned from NHS");

                        alertDialog.setNegativeButton("OK",
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        dialog.cancel();
                                    }
                                });
                        alertDialog.show();
                    }
                    else {
                        Log.d("Login", "Logging in...");
                        Intent myIntent = new Intent(LoginActivity.this, MainActivity.class);
                        myIntent.putExtra(ARG_FROM_MAIN, studentIDinput.getEditText().getText().toString());
                        startActivity(myIntent);
                    }

                    progress.dismiss();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });

        if(IDinput.isEmpty()){
            studentIDinput.setError("Field can't be empty");
            progress.dismiss();
        }
        else if(IDinput.length() != 6)
        {
            studentIDinput.setError("Not a valid Student ID");
            progress.dismiss();
        }
        else
        {
            studentIDinput.setError(null);
            progress.dismiss();
        }
    }
}
