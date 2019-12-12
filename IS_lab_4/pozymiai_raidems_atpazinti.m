function pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
%%  pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
% taikymo pavyzdys:
% pozymiai = pozymiai_raidems_atpazinti('test_data.png', 8) 
%
%%
% Vaizdo su pavyzd�iais nuskaitymas
V = imread(pavadinimas);
figure(12), imshow(V)
%% Raid�i� i�kirpimas ir sud�liojimas � kintamojo 'objektai' celes
V_pustonis = rgb2gray(V);
% vaizdo keitimo dvejetainiu slenkstin�s reik�m�s paie�ka
slenkstis = graythresh(V_pustonis);
% pustonio vaizdo keitimas dvejetainiu
V_dvejetainis = im2bw(V_pustonis,slenkstis);
% rezultato atvaizdavimas
figure(1), imshow(V_dvejetainis)
% vaizde esan�i� objekt� kont�r� paie�ka
V_konturais = edge(uint8(V_dvejetainis));
% rezultato atvaizdavimas
figure(2),imshow(V_konturais)
% objekt� kont�r� u�pildymas 
se = strel('square',7); % strukt�rinis elementas u�pildymui
V_uzpildyti = imdilate(V_konturais, se); 
% rezultato atvaizdavimas
figure(3),imshow(V_uzpildyti)
% tu�tum� objet� viduje u�pildymas
V_vientisi= imfill(V_uzpildyti,'holes');
% rezultato atvaizdavimas
figure(4),imshow(V_vientisi)
% vientis� objekt� dvejetainiame vaizde numeravimas
[O_suzymeti Skaicius] = bwlabel(V_vientisi);
% apskai�iuojami objekt� dvejetainiame vaizde po�ymiai
O_pozymiai = regionprops(O_suzymeti);
% nuskaitomos po�ymi� - objekt� rib� koordina�i� - reik�m�s
O_ribos = [O_pozymiai.BoundingBox];
% kadangi rib� nusako 4 koordinat�s, pergrupuojame reik�mes
O_ribos = reshape(O_ribos,[4 Skaicius]); % Skaicius - objekt� skai�ius
% nuskaitomos po�ymi� - objekt� mas�s centro koordina�i� - reik�m�s
O_centras = [O_pozymiai.Centroid];
% kadangi centr� nusako 2 koordinat�s, pergrupuojame reik�mes
O_centras = reshape(O_centras,[2 Skaicius]);
O_centras = O_centras';
% pridedamas kiekvienam objektui vaize numeris (tre�ias stulpelis �alia koordina�i�)
O_centras(:,3) = 1:Skaicius;
% sur��iojami objektai pagal x koordinat� - stulpel�
O_centras = sortrows(O_centras,2);
% r��iojama atsi�velgiant � pavyzd�i� eilu�i� ir raid�i� skai�i�
raidziu_sk = Skaicius/pvz_eiluciu_sk;
for k = 1:pvz_eiluciu_sk
    O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:) = ...
        sortrows(O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:),3);
end
% i� dvejetainio vaizdo pagal objekt� ribas i�kerpami vaizdo fragmentai
for k = 1:Skaicius
    objektai{k} = imcrop(V_dvejetainis,O_ribos(:,O_centras(k,3)));
end
% vieno i� vaizdo fragment� atvaizdavimas
figure(5),
for k = 1:Skaicius
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
% vaizdo fragmentai apkerpami, panaikinant fon� i� kra�t� (pagal sta�iakamp�)

for k = 1:Skaicius % Skaicius = 88, jei yra 88 raid�s
    V_fragmentas = objektai{k};
    % nustatomas kiekvieno vaizdo fragmento dydis
    [aukstis, plotis] = size(V_fragmentas);
    
    % 1. Balt� stulpeli� naikinimas
    % apskai�iuokime kiekvieno stulpelio sum�
    stulpeliu_sumos = sum(V_fragmentas,1);
    % naikiname tuos stulpelius, kur suma lygi auk��iui
    V_fragmentas(:,stulpeliu_sumos == aukstis) = [];
    % perskai�iuojamas objekto dydis
    [aukstis, plotis] = size(V_fragmentas);
    % 2. Balt� eilu�i� naikinimas
    % apskai�iuokime kiekvienos seilut�s sum�
    eiluciu_sumos = sum(V_fragmentas,2);
    % naikiname tas eilutes, kur suma lygi plo�iui
    V_fragmentas(eiluciu_sumos == plotis,:) = [];
    objektai{k}=V_fragmentas;% �ra�ome vietoje neapkarpyto
end
% vieno i� vaizdo fragment� atvaizdavimas
figure(6),
for k = 1:Skaicius
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
%%
%% Suvienodiname vaizdo fragment� dyd�ius iki 70x50
for k=1:Skaicius
    V_fragmentas=objektai{k};
    V_fragmentas_7050=imresize(V_fragmentas,[70,50]);
    % padalinkime vaizdo fragment� � 10x10 dyd�io dalis
    for m=1:7
        for n=1:5
            % apskai�iuokime kiekvienos dalies vidutin� �viesum� 
            Vid_sviesumas_eilutese=sum(V_fragmentas_7050((m*10-9:m*10),(n*10-9:n*10)));
            Vid_sviesumas((m-1)*5+n)=sum(Vid_sviesumas_eilutese);
        end
    end
    % 10x10 dyd�io dalyje maksimali �viesumo galima reik�m� yra 100
    % normuokime �viesumo reik�mes intervale [0, 1]
    Vid_sviesumas = ((100-Vid_sviesumas)/100);
    % rezultat� (po�mius) neuron� tinklui patogiau pateikti stulpeliu
    Vid_sviesumas = Vid_sviesumas(:);
    % i�saugome apskai�iuotus po�ymius � bendr� kintam�j�
    pozymiai{k} = Vid_sviesumas;
end