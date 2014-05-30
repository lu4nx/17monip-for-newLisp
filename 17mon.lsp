;;;; author: lu4nx <lx@shellcodes.org>
;;;; date: 2014-05-28
;;;; 17MonIP for newLisp

(context 'MonIP)

; 转换点分IPv4地址到32位整型表示
(define (ip2long ip)
  (let ((ip (parse ip "."))
        (long-ip 0))
    (dolist (i ip)
      (setf long-ip (+ (<< long-ip 8)
                       (int i))))
    long-ip))

; 获得点分IPv4地址的A段号
(define (get-ipv4-a ip)
  (int (first (parse ip "."))))

; 判断IP的合法
(define (ip? ip)
  (if (regex {^\d+\.\d+\.\d+\.\d+$} ip)
      true
    nil))

; 获得数据库文件的头偏移
(define (get-offset f)
  (read f buf 4)
  (first (unpack ">lu" buf)))

; 获得索引数据
(define (get-index-data f offset)
  (read f buf (- offset 4))
  buf)

; 从索引数据中找到A段地址
(define (get-ip-index-start ip-a index-data)
  (first (unpack "<lu"
                 ((* ip-a 4) 4 index-data))))

(define (search-address offset start index-data)
  (let ((start-offset (+ 1024 (* start 8)))
        (max-len (- offset 1028))
        (index-offset nil)
        (index-length nil)
        (find? nil))
    (while (and (< start-offset max-len)
                (null? find?))
      (setf start-offset (+ 8 start-offset))
      (if (>= (start-offset 4 index-data) ip)
          (begin
            (setf index-offset (first (unpack "<lu"
                                              (append ((+ 4 start-offset)
                                                       3
                                                       index-data)
                                                      (char 0)))))
            (setf index-length (first (unpack "c" ((+ 7 start-offset)
                                                   1
                                                   index-data))))
            (setf find? true))))
    (if (true? find?)
        (list index-offset index-length)
      nil)))

; 从IP库中的读出地理位置
(define (get-ip-address f offset index-offset index-length)
  (seek f (+ offset (- index-offset 1024)))
  (read f buf index-length)
  (close f)
  (parse buf "\t"))

(define (find-ip ip)
  (if (null? (ip? ip))
      nil
    (begin
      (letn ((f (open "17monipdb.dat" "read"))
             (offset (get-offset f))
             (index-data (get-index-data f offset))
             (ip-a (get-ipv4-a ip))
             (ip (pack ">lu" (ip2long ip)))
             (start (get-ip-index-start ip-a index-data))
             (search-result (search-address offset start index-data)))
        (if search-result
            (get-ip-address f offset (nth 0 search-result) (nth 1 search-result))
          nil)))))

(context MAIN)

;; Example
;;(println (MonIP:find-ip "8.8.8.8"))
