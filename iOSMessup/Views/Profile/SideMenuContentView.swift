//
//  SideMenuContentView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

//TODO: This view needs to be redesigned to match the app design
struct SideMenuContentView: View {
    
    var body: some View {
        HStack {
            ZStack{
                Rectangle()
                    .fill(.mintAccent)
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ProfileImageView()
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                    VStack(spacing: 40) {
                        DrawerOptionButton(text: "Profile", icon: "person")
                        DrawerOptionButton(text: "Recents", icon: "clock.arrow.circlepath")
                        DrawerOptionButton(text: "Settings", icon: "gearshape")
                    }.padding(.top)
                    Spacer()

                    Button {
                        
                    } label : {
                        HStack {
                            Text("Sign out")
                                .font(.title3)
                                .padding()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(.red)
                        .clipShape(.rect)
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .clipShape(.rect)
                .frame(width: UIScreen.main.bounds.width / 2)
            }
            Spacer()
        }
    }
    
    @ViewBuilder func ProfileImageView() -> some View{
        VStack(alignment: .center){
            Image("logoImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(.circle)
                .shadow(radius: 8)
                .padding(.top, 10)
            
            Text("Rafael Serrano")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.accent)
                .padding(.top, 10)
            
            Text("IOS Developer")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.accent.opacity(0.5))
        }
    }
}


#Preview {
    SideMenuContentView()
}
