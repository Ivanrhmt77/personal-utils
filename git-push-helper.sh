#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi untuk menampilkan pesan berwarna
print_colored() {
    echo -e "${1}${2}${NC}"
}

# Fungsi untuk menampilkan header
print_header() {
    print_colored $BLUE "=================================="
    print_colored $BLUE "   Git Push Helper dengan"
    print_colored $BLUE "   Conventional Commit Format"
    print_colored $BLUE "=================================="
    echo
}

# Fungsi untuk menampilkan tipe commit yang tersedia
show_commit_types() {
    print_colored $YELLOW "Tipe commit yang tersedia:"
    echo "1. feat     - Fitur baru"
    echo "2. fix      - Perbaikan bug"
    echo "3. docs     - Perubahan dokumentasi"
    echo "4. style    - Perubahan format kode (white-space, formatting, dll)"
    echo "5. refactor - Refactoring kode tanpa mengubah fungsionalitas"
    echo "6. test     - Menambah atau mengubah test"
    echo "7. chore    - Perubahan pada build process atau auxiliary tools"
    echo "8. perf     - Perubahan untuk meningkatkan performa"
    echo "9. ci       - Perubahan pada CI/CD configuration"
    echo "10. revert  - Membatalkan commit sebelumnya"
    echo
}

# Fungsi untuk validasi input tipe commit
validate_commit_type() {
    local type=$1
    case $type in
        feat|fix|docs|style|refactor|test|chore|perf|ci|revert)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Fungsi utama
main() {
    print_header
    
    # Cek apakah berada di dalam git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_colored $RED "Error: Tidak berada di dalam git repository!"
        exit 1
    fi
    
    # Cek status git
    if [[ -z $(git status --porcelain) ]]; then
        print_colored $YELLOW "Tidak ada perubahan yang perlu di-commit."
        exit 0
    fi
    
    print_colored $GREEN "Status repository saat ini:"
    git status --short
    echo
    
    # Pilihan untuk menambahkan file
    print_colored $YELLOW "Pilih cara menambahkan file:"
    echo "1. Tambahkan semua file (git add .)"
    echo "2. Pilih file secara interaktif"
    echo "3. Keluar (gunakan git add manual)"
    echo
    
    read -p "Pilihan Anda (1/2/3): " add_choice
    
    case $add_choice in
        1)
            git add .
            print_colored $GREEN "✓ Semua file telah ditambahkan ke staging area"
            ;;
        2)
            # Interactive file selection
            print_colored $BLUE "File yang tersedia untuk di-add:"
            
            # Dapatkan daftar file yang berubah
            mapfile -t changed_files < <(git status --porcelain | awk '{print $2}')
            
            if [ ${#changed_files[@]} -eq 0 ]; then
                print_colored $YELLOW "Tidak ada file yang berubah."
                exit 0
            fi
            
            # Tampilkan file dengan nomor
            for i in "${!changed_files[@]}"; do
                status=$(git status --porcelain "${changed_files[$i]}" | cut -c1-2)
                echo "$((i+1)). ${changed_files[$i]} [$status]"
            done
            
            echo "$((${#changed_files[@]}+1)). Pilih semua file"
            echo
            
            # Input pilihan file
            selected_files=()
            while true; do
                read -p "Pilih nomor file (pisahkan dengan spasi, atau 'done' untuk selesai): " file_input
                
                if [[ "$file_input" == "done" ]]; then
                    break
                fi
                
                # Parse input
                for num in $file_input; do
                    if [[ "$num" =~ ^[0-9]+$ ]]; then
                        if [ "$num" -eq "$((${#changed_files[@]}+1))" ]; then
                            # Pilih semua file
                            selected_files=("${changed_files[@]}")
                            break 2
                        elif [ "$num" -ge 1 ] && [ "$num" -le "${#changed_files[@]}" ]; then
                            file_index=$((num-1))
                            if [[ ! " ${selected_files[*]} " =~ " ${changed_files[$file_index]} " ]]; then
                                selected_files+=("${changed_files[$file_index]}")
                            fi
                        else
                            print_colored $RED "Nomor $num tidak valid!"
                        fi
                    else
                        print_colored $RED "Input tidak valid: $num"
                    fi
                done
                
                if [ ${#selected_files[@]} -gt 0 ]; then
                    echo
                    print_colored $BLUE "File yang dipilih:"
                    printf '%s\n' "${selected_files[@]}"
                    echo
                fi
            done
            
            if [ ${#selected_files[@]} -eq 0 ]; then
                print_colored $YELLOW "Tidak ada file yang dipilih. Keluar..."
                exit 0
            fi
            
            # Add selected files
            for file in "${selected_files[@]}"; do
                git add "$file"
                print_colored $GREEN "✓ Added: $file"
            done
            ;;
        3)
            print_colored $YELLOW "Script dihentikan. Silakan gunakan 'git add' manual."
            exit 0
            ;;
        *)
            print_colored $RED "Pilihan tidak valid!"
            exit 1
            ;;
    esac
    
    echo
    show_commit_types
    
    # Input tipe commit
    while true; do
        read -p "Pilih tipe commit (atau ketik langsung): " commit_type
        
        # Konversi nomor ke tipe
        case $commit_type in
            1) commit_type="feat" ;;
            2) commit_type="fix" ;;
            3) commit_type="docs" ;;
            4) commit_type="style" ;;
            5) commit_type="refactor" ;;
            6) commit_type="test" ;;
            7) commit_type="chore" ;;
            8) commit_type="perf" ;;
            9) commit_type="ci" ;;
            10) commit_type="revert" ;;
        esac
        
        if validate_commit_type "$commit_type"; then
            break
        else
            print_colored $RED "Tipe commit tidak valid! Silakan pilih dari daftar yang tersedia."
        fi
    done
    
    # Input scope (opsional)
    read -p "Scope/area perubahan (opsional, tekan Enter untuk skip): " scope
    
    # Input deskripsi commit
    while true; do
        read -p "Deskripsi commit (wajib): " description
        if [[ -n "$description" ]]; then
            break
        else
            print_colored $RED "Deskripsi commit tidak boleh kosong!"
        fi
    done
    
    # Input body commit (opsional)
    read -p "Body commit - penjelasan detail (opsional, tekan Enter untuk skip): " body
    
    # Input breaking change (opsional)
    read -p "Breaking change? Jelaskan jika ada (opsional): " breaking_change

    # Optional reference (misal ticket ID, issue, atau PR)
    read -p "Reference (ref) jika ada (opsional): " ref
    
    # Membuat pesan commit sesuai conventional commit
    if [[ -n "$scope" ]]; then
        commit_msg="$commit_type($scope): $description"
    else
        commit_msg="$commit_type: $description"
    fi
    
    # Menambahkan body jika ada
    if [[ -n "$body" ]]; then
        commit_msg="$commit_msg

$body"
    fi
    
    # Menambahkan breaking change jika ada
    if [[ -n "$breaking_change" ]]; then
        commit_msg="$commit_msg

BREAKING CHANGE: $breaking_change"
    fi

    # Menambahkan reference jika ada
    if [[ -n "$ref" ]]; then
        commit_msg="$commit_msg

Ref: $ref"
    fi
    
    echo
    print_colored $YELLOW "Preview commit message:"
    print_colored $BLUE "$commit_msg"
    echo
    
    # Konfirmasi commit
    read -p "Lanjutkan dengan commit ini? (y/n): " confirm_commit
    if [[ $confirm_commit =~ ^[Yy]$ ]]; then
        if git commit -m "$commit_msg"; then
            print_colored $GREEN "✓ Commit berhasil!"
        else
            print_colored $RED "✗ Commit gagal!"
            exit 1
        fi
    else
        print_colored $YELLOW "Commit dibatalkan."
        exit 0
    fi
    
    # Konfirmasi push
    echo
    current_branch=$(git branch --show-current)
    read -p "Push ke remote repository (branch: $current_branch)? (y/n): " confirm_push
    if [[ $confirm_push =~ ^[Yy]$ ]]; then
        if git push origin "$current_branch"; then
            print_colored $GREEN "✓ Push berhasil ke branch '$current_branch'!"
        else
            print_colored $RED "✗ Push gagal!"
            # Coba push dengan set upstream jika branch baru
            read -p "Branch mungkin belum ada di remote. Set upstream dan push? (y/n): " set_upstream
            if [[ $set_upstream =~ ^[Yy]$ ]]; then
                if git push -u origin "$current_branch"; then
                    print_colored $GREEN "✓ Push berhasil dengan set upstream!"
                else
                    print_colored $RED "✗ Push tetap gagal!"
                    exit 1
                fi
            fi
        fi
    else
        print_colored $YELLOW "Push dibatalkan. Commit sudah tersimpan lokal."
    fi
    
    echo
    print_colored $GREEN "Selesai! 🎉"
}

# Jalankan fungsi utama
main "$@"