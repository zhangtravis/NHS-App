package com.example.hamiltonnhs;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.ArrayList;

public class VolunteerOpportunities extends Fragment {

    private static ListView listView;
    private DatabaseReference ref;
    ArrayList<String> voloppinfo;
    ArrayAdapter<String> arrayAdapter;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.volunteer_opportunities, container, false);

        ref = FirebaseDatabase.getInstance().getReference();
        voloppinfo = new ArrayList<>();

        listView = view.findViewById(R.id.volunteeropp);
        listView.setClickable(true);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                String path = voloppinfo.get(i);
                VolunteerOppInfo nextfrag = new VolunteerOppInfo();
                Bundle args = new Bundle();
                args.putString("Path", path);
                nextfrag.setArguments(args);
                FragmentTransaction fragmentTransaction = getActivity().getSupportFragmentManager().beginTransaction();
                fragmentTransaction.replace(((ViewGroup)getView().getParent()).getId(), nextfrag);
                fragmentTransaction.addToBackStack("VolunteerOppInfo");
                fragmentTransaction.commit();
            }
        });

        arrayAdapter = new ArrayAdapter<>(getActivity(), android.R.layout.simple_list_item_1, voloppinfo);

        listView.setAdapter(arrayAdapter);

        ref.child("Volunteer Opps").addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {
                String value = dataSnapshot.getKey();
                voloppinfo.add(value);
                arrayAdapter.notifyDataSetChanged();
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {

            }

            @Override
            public void onChildRemoved(@NonNull DataSnapshot dataSnapshot) {

            }

            @Override
            public void onChildMoved(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {

            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });

        return view;
    }
}
